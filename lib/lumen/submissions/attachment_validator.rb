# frozen_string_literal: true

class Lumen::Submissions::AttachmentValidator
  def initialize(payload)
    @payload = payload
  end

  def validate(errors)
    valid = true

    Lumen::Submissions::Attachment.entries(payload).each do |_key, attributes|
      kind = attributes['kind'] || attributes[:kind]
      kind = 'supporting' if kind.blank?
      unless FileUpload::ALLOWED_KINDS.include?(kind)
        errors.add(:file_uploads, "kind #{kind.inspect} is invalid")
        valid = false
      end

      filename = attributes['file_name'] || attributes[:file_name]
      if filename.present? && filename.length > 255
        errors.add(:file_uploads, 'filename is too long')
        valid = false
      end

      begin
        Lumen::Submissions::Attachment.decode(
          Lumen::Submissions::Attachment.file_value(attributes)
        )
      rescue Lumen::Submissions::Attachment::InvalidAttachment => error
        errors.add(:file_uploads, error.message)
        valid = false
      end
    end

    valid
  end

  private

  attr_reader :payload
end
