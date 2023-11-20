class GoogleSenderRedactor
  REDACTION_REGEX = /google|youtube/i

  def redact(instance)
    return unless (instance.recipient_name =~ REDACTION_REGEX).present?

    instance.sender.name_original = instance.sender.name
    instance.principal.name_original = instance.principal.name
    instance.sender.name = Lumen::REDACTION_MASK
    instance.principal.name = Lumen::REDACTION_MASK
    instance.save
  end
end
