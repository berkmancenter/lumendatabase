class InstanceRedactor
  attr_reader :redactors

  def initialize(
    redactors = [
      Redactors::PhoneNumberRedactor.new,
      Redactors::SsnRedactor.new,
      Redactors::EmailRedactor.new
    ],
    options = {}
  )
    @redactors = redactors
    @options = options
  end

  def redact(instance, field_or_fields = Notice::REDACTABLE_FIELDS)
    Array(field_or_fields).each do |field|
      next unless (text = instance.send(field)).present?

      redact_field(instance, field, text)
      update_original(instance, field, text)
    end
  end

  def redact_all(instance_ids,
                 field_or_fields = Notice::REDACTABLE_FIELDS,
                 klass = Notice)
    klass.where(id: instance_ids).each do |instance|
      redact(instance, field_or_fields)
      instance.save
    end
  end

  private

  def redact_field(instance, field, text)
    new_text = redactors.inject(text) do |result, redactor|
      redactor.redact(result, @options)
    end

    return unless new_text != text

    instance.send(:"#{field}=", new_text)
  end

  def update_original(instance, field, text)
    return unless instance.respond_to?("#{field}_original")
    return unless instance.send(:"#{field}_original").blank?
    return if instance.send(:"#{field}") == text

    instance.send(:"#{field}_original=", text)
  end
end
