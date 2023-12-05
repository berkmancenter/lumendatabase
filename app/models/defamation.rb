# frozen_string_literal: true

class Defamation < Notice
  load_elasticsearch_helpers

  def self.model_name
    Notice.model_name
  end

  def to_partial_path
    'notices/notice'
  end

  def auto_redact
    custom_redactors = [
      Redactors::PhoneNumberRedactor.new,
      Redactors::SsnRedactor.new,
      Redactors::EmailRedactor.new,
      Redactors::EntityNameRedactor.new
    ]

    entity_name = principal&.name || sender&.name

    # Some submitters redact on their end using this phrase, let's avoid
    # double-redaction
    return if entity_name == Lumen::REDACTION_MASK

    instance_redactor = InstanceRedactor.new(
      custom_redactors,
      {
        entity_name: entity_name
      }
    )

    instance_redactor.redact(self)

    works.each do |work|
      instance_redactor.redact(work, %w[description])

      work.infringing_urls.each do |url|
        instance_redactor.redact(url, %w[url])
      end

      work.copyrighted_urls.each do |url|
        instance_redactor.redact(url, %w[url])
      end
    end

    Redactors::GoogleSenderRedactor.new.redact(self)
  end

  def as_indexed_json(_options)
    out = super(_options)

    if out.key?('works')
      out['works'] = out['works'].map do |work|
        work.except('description')
      end
    end

    out
  end
end
