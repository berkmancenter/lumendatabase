# frozen_string_literal: true

require 'digest'

class Lumen::Submissions::AttachmentStager
  def initialize(submission_request)
    @submission_request = submission_request
  end

  def stage
    submission_request.with_lock do
      return submission_request if submission_request.completed?

      entries = Lumen::Submissions::Attachment.entries(
        submission_request.payload
      )
      if staging_complete?(entries)
        mark_staged!
        return submission_request
      end

      submission_request.uploads.destroy_all
      entries.each do |parameter_key, attributes|
        stage_upload(parameter_key, attributes)
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

  def stage_upload(parameter_key, attributes)
    data_uri = Lumen::Submissions::Attachment.file_value(attributes)
    content_type, bytes = Lumen::Submissions::Attachment.decode(data_uri)
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
    return if upload.file.attached?

    raise Lumen::Submissions::Attachment::InvalidAttachment,
          'could not be stored'
  end
end
