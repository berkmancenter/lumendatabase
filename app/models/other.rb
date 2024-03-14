# frozen_string_literal: true

class Other < Notice
  load_elasticsearch_helpers

  def self.model_name
    Notice.model_name
  end

  def to_partial_path
    'notices/notice'
  end

  def auto_redact
    InstanceRedactor.new.redact(self)
    Redactors::GoogleSenderRedactor.new.redact(self)
    redact_urls
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
