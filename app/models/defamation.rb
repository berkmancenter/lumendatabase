# frozen_string_literal: true

class Defamation < Notice
  MASK = 'REDACTED'
  REDACTION_REGEX = /google|youtube/i

  define_elasticsearch_mapping(works: [:description])

  def self.model_name
    Notice.model_name
  end

  def to_partial_path
    'notices/notice'
  end

  def sender_name
    if hide_identities?
      MASK
    else
      super
    end
  end

  def principal_name
    if hide_identities?
      MASK
    else
      super
    end
  end

  def hide_identities?
    (recipient_name =~ REDACTION_REGEX).present?
  end

  def auto_redact
    custom_redactors = [
      InstanceRedactor::PhoneNumberRedactor.new,
      InstanceRedactor::SSNRedactor.new,
      InstanceRedactor::EmailRedactor.new,
      InstanceRedactor::EntityNameRedactor.new
    ]

    instance_redactor = InstanceRedactor.new(
      custom_redactors,
      {
        entity_name: principal&.name || sender&.name
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
  end
end
