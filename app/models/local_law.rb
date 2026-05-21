# frozen_string_literal: true

class LocalLaw < Notice
  load_elasticsearch_helpers

  def self.model_name
    Notice.model_name
  end

  def self.label
    'Local Law'
  end

  def to_partial_path
    'notices/notice'
  end

  def auto_redact
    InstanceRedactor.new.redact(self)
    Redactors::GoogleSenderRedactor.new.redact(self)
    redact_urls
  end

  def works_attributes=(works_attrs)
    super

    works.each do |work|
      work.description = nil
      work.copyrighted_urls = []
      work.infringing_urls = []
    end
  end

  def as_indexed_json(_options)
    out = super(_options)
    out['works'] = []
    out
  end
end
