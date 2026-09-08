# frozen_string_literal: true

require 'tempfile'

class Lumen::Submissions::AttachmentValidator
  def initialize(payload)
    @payload = payload
  end

  def validate(errors)
    valid = true
    total_bytes = 0
    entries = Lumen::Submissions::Attachment.limited_entries(payload)

    entries.each do |key, attributes|
      begin
        content_type, bytes = Lumen::Submissions::Attachment.decode(
          Lumen::Submissions::Attachment.file_value(attributes)
        )
        total_bytes = Lumen::Submissions::Attachment.add_to_total_size!(
          total_bytes,
          bytes.bytesize
        )
      rescue Lumen::Submissions::Attachment::InvalidAttachment => error
        errors.add(:file_uploads, error.message)
        valid = false
        next
      end

      upload_valid = validate_file_upload(
        key,
        attributes,
        content_type,
        bytes,
        errors
      )
      valid = false unless upload_valid
    end

    valid
  rescue Lumen::Submissions::Attachment::InvalidAttachment => error
    errors.add(:file_uploads, error.message)
    false
  end

  private

  attr_reader :payload

  def validate_file_upload(key, attributes, content_type, bytes, errors)
    file_upload = nil

    Tempfile.create('notice-submission-validation') do |tempfile|
      tempfile.binmode
      tempfile.write(bytes)
      tempfile.rewind

      filename = (attributes['file_name'] || attributes[:file_name]).presence ||
                 "attachment-#{key}"
      uploaded_file = ActionDispatch::Http::UploadedFile.new(
        tempfile: tempfile,
        filename: filename,
        type: content_type
      )
      file_upload = FileUpload.new(
        kind: attributes['kind'] || attributes[:kind],
        file_name: attributes['file_name'] || attributes[:file_name]
      )
      file_upload.file.post_processing = false
      file_upload.file = uploaded_file

      file_upload.valid?
      copy_file_upload_errors(file_upload, errors)
      file_upload.errors.empty?
    end
  ensure
    close_queued_files(file_upload)
  end

  def copy_file_upload_errors(file_upload, errors)
    file_upload.errors.each do |error|
      errors.add(:file_uploads, error.full_message)
    end
  end

  def close_queued_files(file_upload)
    return unless file_upload

    file_upload.file.queued_for_write.each_value do |file|
      file.close! if file.respond_to?(:close!)
    end
    file_upload.file.clear
  end
end
