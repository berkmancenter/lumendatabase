# frozen_string_literal: true

class Work
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveRecord::Validations

  attr_accessor :description, :description_original, :kind, :infringing_urls, :copyrighted_urls

  UNKNOWN_WORK_DESCRIPTION = 'Unknown work'.freeze
  REDACTABLE_FIELDS = %w[description].freeze

  validates_associated :infringing_urls, :copyrighted_urls

  def initialize(*)
    super
    init_urls
  end

  # == Class Methods ===========================================================
  def self.unknown
    @unknown ||= Work.new(
      kind: 'unknown',
      description: UNKNOWN_WORK_DESCRIPTION
    )
  end

  # == Instance Methods ========================================================
  def init_urls
    self.infringing_urls = self.infringing_urls.map { |url| InfringingUrl.new(url) } if self.infringing_urls&.first.is_a?(Hash)
    self.copyrighted_urls = self.copyrighted_urls.map { |url| CopyrightedUrl.new(url) } if self.copyrighted_urls&.first.is_a?(Hash)
    self.infringing_urls = [] unless self.infringing_urls.present?
    self.copyrighted_urls = [] unless self.copyrighted_urls.present?
  end

  def infringing_urls_attributes=(urls)
    self.infringing_urls = urls.map { |url| InfringingUrl.new(url) }
  end

  def copyrighted_urls_attributes=(urls)
    self.copyrighted_urls = urls.map { |url| CopyrightedUrl.new(url) }
  end

  def infringing_urls_counted_by_domain
    @infringing_urls_counted_by_domain  ||= count_by_domain(infringing_urls)
  end

  def copyrighted_urls_counted_by_domain
    @copyrighted_urls_counted_by_domain ||= count_by_domain(copyrighted_urls)
  end

  def force_redactions
    auto_redact

    # DeterminesWorkKind is intended for use here but disabled due to confusion
    # caused by mis-classified works.
    self.kind = 'Unspecified' if kind.blank?
  end

  def fix_concatenated_urls
    self.copyrighted_urls += fixed_urls(:copyrighted_urls)
    self.infringing_urls += fixed_urls(:infringing_urls)
  end

  def as_json(*)
    {
      description: self.description,
      kind: self.kind,
      infringing_urls: self.infringing_urls,
      copyrighted_urls: self.copyrighted_urls
    }
  end

  # == Private Methods =========================================================
  private

  def count_by_domain(urls)
    counted_urls = {}

    urls.each do |url|
      uri = Addressable::URI.parse(url.url)

      # get just domain
      domain = uri.host

      if counted_urls[domain].nil?
        counted_urls[domain] = {
          domain: domain,
          count: 1
        }
      else
        counted_urls[domain][:count] += 1
      end
    end

    counted_urls
      .values
      .sort_by! { |url| url[:count] }
      .reverse!
  end

  def fixed_urls(url_type)
    new_urls = []
    self.send(url_type).each do |url_obj|
      next unless url_obj[:url]&.scan('/http').present?

      split_urls = conservative_split(url_obj[:url])
      # Overwrite the current URL with one of the split-apart URLs. Then
      # add the rest of the split-apart URLs to a list for safekeeping.
      url_obj[:url] = split_urls.pop()
      split_urls_as_hashes = split_urls.map { |url| { url: url } }
      new_urls << self.send(url_type).build(split_urls_as_hashes)
    end
    new_urls
  end

  # We can't just split on 'http', because doing so will result in strings
  # which no longer contain it. We need to look at the pairs of 'http' and
  # $the_rest_of_the_URL which split produces and then mash them back together.
  # Note: this will NOT WORK on URLs which contain other URLs as
  # path/querystring options, like Wayback Machine URLs. Unfortunately URLs do
  # not follow a regular grammar so we have a mess of twisty little edge cases.
  # If they become a problem in the wild, we can deal with it then.
  def conservative_split(s)
    b = []
    s.split(/(https?:\/\/)/).reject { |x| x.blank? }.each_slice(2) { |s| b << s.join }
    b
  end

  def auto_redact
    InstanceRedactor.new.redact(self, REDACTABLE_FIELDS)
  end

  def new_record?
    true
  end
end
