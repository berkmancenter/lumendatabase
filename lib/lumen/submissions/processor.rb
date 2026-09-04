# frozen_string_literal: true

require 'digest'

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
    submission_request.update!(
      status: 'completed',
      attempts: submission_request.attempts + 1,
      completed_at: Time.current,
      failed_at: nil,
      failure_class: nil,
      failure_message: nil
    )
    notice
  end

  def with_staged_uploads(payload, uploads = staged_uploads, index = 0, &block)
    verify_upload_count!(payload, uploads) if index.zero?
    return yield(payload) if index >= uploads.length

    upload = uploads[index]
    upload.file.blob.open do |tempfile|
      verify_checksum!(upload, tempfile)
      file_attributes(payload, upload)['file'] =
        ActionDispatch::Http::UploadedFile.new(
          tempfile: tempfile,
          filename: upload.original_filename,
          type: upload.content_type
        )

      with_staged_uploads(payload, uploads, index + 1, &block)
    end
  rescue ActiveStorage::FileNotFoundError, Errno::ENOENT => error
    raise StagedAttachmentError,
          "Staged upload #{upload.id} is unavailable: #{error.message}"
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

  def verify_upload_count!(payload, uploads)
    expected_count = Lumen::Submissions::Attachment.entries(payload).count
    return if uploads.count == expected_count

    raise StagedAttachmentError,
          "Expected #{expected_count} staged uploads, found #{uploads.count}"
  end
end
