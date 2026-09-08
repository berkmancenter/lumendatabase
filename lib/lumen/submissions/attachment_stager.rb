# frozen_string_literal: true

require 'digest'

class Lumen::Submissions::AttachmentStager
  def initialize(submission_request)
    @submission_request = submission_request
  end

  def stage
    submission_request.with_lock do
      return submission_request if submission_request.completed?

      entries = Lumen::Submissions::Attachment.limited_entries(
        submission_request.payload
      )
      if staging_complete?(entries)
        validate_staged_upload_sizes!
        mark_staged!
        return submission_request
      end

      submission_request.uploads.destroy_all
      total_bytes = 0
      entries.each do |parameter_key, attributes|
        total_bytes = stage_upload(parameter_key, attributes, total_bytes)
      end
      mark_staged!
    end

    submission_request
  end

  private

  attr_reader :submission_request

  def mark_staged!
    submission_request.update!(
      status: 'processing',
      failed_at: nil,
      failure_class: nil,
      failure_message: nil
    )
  end

  def staging_complete?(entries)
    uploads = submission_request.uploads.includes(file_attachment: :blob).to_a
    expected_keys = entries.map do |parameter_key, _attributes|
      parameter_key.to_s
    end
    actual_keys = uploads.map(&:parameter_key)

    actual_keys.sort == expected_keys.sort &&
      uploads.all? { |upload| upload.file.attached? }
  end

  def stage_upload(parameter_key, attributes, total_bytes)
    data_uri = Lumen::Submissions::Attachment.file_value(attributes)
    content_type, bytes = Lumen::Submissions::Attachment.decode(data_uri)
    total_bytes = Lumen::Submissions::Attachment.add_to_total_size!(
      total_bytes,
      bytes.bytesize
    )
    original_filename = attributes['file_name'].presence ||
                        attributes[:file_name].presence ||
                        "attachment-#{parameter_key}"
    upload = submission_request.uploads.create!(
      parameter_key: parameter_key.to_s,
      kind: (attributes['kind'] || attributes[:kind]).presence ||
            Lumen::Submissions::Attachment::DEFAULT_KIND,
      original_filename: original_filename,
      content_type: content_type,
      byte_size: bytes.bytesize,
      checksum: Digest::SHA256.hexdigest(bytes)
    )
    upload.file.attach(
      io: StringIO.new(bytes),
      filename: original_filename,
      content_type: content_type
    )
    return total_bytes if upload.file.attached?

    raise Lumen::Submissions::Attachment::InvalidAttachment,
          'could not be stored'
  end

  def validate_staged_upload_sizes!
    total_bytes = 0
    submission_request.uploads.find_each do |upload|
      Lumen::Submissions::Attachment.validate_file_size!(upload.byte_size)
      total_bytes = Lumen::Submissions::Attachment.add_to_total_size!(
        total_bytes,
        upload.byte_size
      )
    end
  end
end
