# frozen_string_literal: true

require 'digest'
require 'tempfile'

class Lumen::Submissions::Processor
  class StagedAttachmentError < StandardError; end

  def initialize(submission_request)
    @submission_request = submission_request
  end

  def process
    submission_request.with_lock do
      return submission_request.notice if submission_request.completed?

      if (existing_notice = submission_request.notice)
        mark_completed!(existing_notice)
        return existing_notice
      end

      submission_request.update!(status: 'processing', started_at: Time.current)

      with_staged_uploads(submission_request.payload.deep_dup) do |payload|
        notice = Lumen::NoticeBuilder.new(
          notice_class,
          payload,
          nil,
          submitter_entity: submission_request.submitter_entity
        ).build
        notice.id = submission_request.reserved_notice_id
        notice.save!
        notice.mark_for_review
        mark_completed!(notice)
        notice
      end
    end
  end

  private

  attr_reader :submission_request

  def notice_class
    submission_request.notice_type.constantize.tap do |model_class|
      raise NameError, 'Invalid notice type' unless model_class < Notice
    end
  end

  def mark_completed!(notice)
    # Payload and staged uploads are needed only while a receipt can retry.
    # Destroying them in this transaction keeps them if finalization rolls
    # back; Active Storage purges the unreferenced blobs after commit.
    submission_request.update!(
      status: 'completed',
      payload: {},
      attempts: submission_request.attempts + 1,
      completed_at: Time.current,
      next_attempt_at: nil,
      failed_at: nil,
      failure_class: nil,
      failure_message: nil
    )
    submission_request.uploads.find_each(&:destroy!)
    notice
  end

  def with_staged_uploads(payload)
    uploads = staged_uploads
    verify_uploads!(payload, uploads)
    tempfiles = []
    total_bytes = 0

    uploads.each do |upload|
      tempfile, file_bytes = download_to_tempfile(upload, total_bytes)
      tempfiles << tempfile
      total_bytes += file_bytes
      file_attributes(payload, upload)['file'] =
        ActionDispatch::Http::UploadedFile.new(
          tempfile: tempfile,
          filename: upload.original_filename,
          type: upload.content_type
        )
    end

    yield(payload)
  ensure
    tempfiles&.each(&:close!)
  end

  def download_to_tempfile(upload, existing_total_bytes)
    tempfile = Tempfile.new('notice-submission-processing')
    tempfile.binmode
    file_bytes = 0

    upload.file.blob.download do |chunk|
      file_bytes += chunk.bytesize
      Lumen::Submissions::Attachment.validate_file_size!(file_bytes)
      Lumen::Submissions::Attachment.add_to_total_size!(
        existing_total_bytes,
        file_bytes
      )
      tempfile.write(chunk)
    end
    tempfile.flush
    tempfile.rewind
    verify_checksum!(upload, tempfile)
    [tempfile, file_bytes]
  rescue ActiveStorage::FileNotFoundError, Errno::ENOENT,
         Lumen::Submissions::Attachment::InvalidAttachment => error
    tempfile&.close!
    raise StagedAttachmentError,
          "Staged upload #{upload.id} is invalid: #{error.message}"
  rescue StandardError
    tempfile&.close!
    raise
  end

  def verify_checksum!(upload, tempfile)
    actual_checksum = Digest::SHA256.file(tempfile.path).hexdigest
    return if ActiveSupport::SecurityUtils.secure_compare(
      actual_checksum,
      upload.checksum
    )

    raise StagedAttachmentError,
          "Checksum mismatch for staged upload #{upload.id}"
  end

  def staged_uploads
    @staged_uploads ||= submission_request.uploads
                                           .includes(file_attachment: :blob)
                                           .order(:id)
                                           .to_a
  end

  def file_attributes(payload, upload)
    attributes = payload.fetch('file_uploads_attributes')

    if attributes.is_a?(Array)
      attributes.fetch(upload.parameter_key.to_i)
    else
      attributes.fetch(upload.parameter_key)
    end
  end

  def verify_uploads!(payload, uploads)
    expected_count = Lumen::Submissions::Attachment
      .limited_entries(payload)
      .count
    unless uploads.count == expected_count
      raise StagedAttachmentError,
            "Expected #{expected_count} staged uploads, found #{uploads.count}"
    end

    total_bytes = 0
    uploads.each do |upload|
      Lumen::Submissions::Attachment.validate_file_size!(upload.byte_size)
      total_bytes = Lumen::Submissions::Attachment.add_to_total_size!(
        total_bytes,
        upload.byte_size
      )
    end
  rescue Lumen::Submissions::Attachment::InvalidAttachment => error
    raise StagedAttachmentError, error.message
  end
end
