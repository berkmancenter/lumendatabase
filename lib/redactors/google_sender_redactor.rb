class GoogleSenderRedactor
  REDACTION_REGEX = /google|youtube/i

  def redact(instance)
    return unless (instance.recipient_name =~ REDACTION_REGEX).present?

    need_save = redact_entity(instance.sender) || redact_entity(instance.principal)

    instance.save if need_save
  end

  private

  def redact_entity(entity)
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
