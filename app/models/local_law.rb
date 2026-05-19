# frozen_string_literal: true

class LocalLaw < Other
  def self.label
    'Local Law'
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
