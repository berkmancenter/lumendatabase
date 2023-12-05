module Redactors
  class Redactors::GoogleSenderRedactor
    REDACTION_REGEX = /google|youtube/i

    def redact(instance)
      return if instance.recipient.nil?
      return unless (instance.recipient_name =~ REDACTION_REGEX).present?

      sender_redacted = redact_entity(instance.sender)
      principal_redacted = redact_entity(instance.principal)

      instance.save if sender_redacted || principal_redacted
    end

    private

    def redact_entity(entity)
      return if entity.nil?

      if entity.name != Lumen::REDACTION_MASK
        entity.name_original = entity.name
        entity.name = Lumen::REDACTION_MASK
        true
      else
        unless entity.name_original.present?
          entity.name_original = Lumen::REDACTION_MASK
          true
        end
      end
    end
  end
end
