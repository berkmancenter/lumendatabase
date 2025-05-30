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
    self.infringing_urls = self.infringing_urls.map { |url| valid_url(InfringingUrl, url) }.compact if self.infringing_urls&.first.is_a?(Hash)
    self.copyrighted_urls = self.copyrighted_urls.map { |url| valid_url(CopyrightedUrl, url) }.compact if self.copyrighted_urls&.first.is_a?(Hash)
    self.infringing_urls = [] unless self.infringing_urls.present?
    self.copyrighted_urls = [] unless self.copyrighted_urls.present?
  end

  def infringing_urls_attributes=(urls)
    self.infringing_urls = urls.map { |url| valid_url(InfringingUrl, url) }.compact
  end

  def copyrighted_urls_attributes=(urls)
    self.copyrighted_urls = urls.map { |url| valid_url(CopyrightedUrl, url) }.compact
  end

  def infringing_urls_counted_by_fqdn
    @infringing_urls_counted_by_fqdn  ||= count_by_fqdn(infringing_urls)
  end

  def copyrighted_urls_counted_by_fqdn
    @copyrighted_urls_counted_by_fqdn ||= count_by_fqdn(copyrighted_urls)
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

  def self.fqdn_from_url(url)
    begin
      # Valid URIs
      uri = Addressable::URI.parse(url)
      fqdn = uri.host
    rescue Addressable::URI::InvalidURIError
      # Invalid URIs
      part = url.split('/')[2]
      fqdn = part&.split(' ')&.first || url
      fqdn = fqdn.gsub(/^www\./, '')
    end

    fqdn
  end

  def infringing_urls_public
    filter_urls(infringing_urls)
  end

  def copyrighted_urls_public
    filter_urls(copyrighted_urls)
  end

  # == Private Methods =========================================================
  private

  def count_by_fqdn(urls)
    counted_urls = {}

    urls.each do |url|
      next if url.url.nil?

      fqdn = Work.fqdn_from_url(url.url)

      if counted_urls[fqdn].nil?
        counted_urls[fqdn] = {
          fqdn: fqdn,
          count: 1
        }
      else
        counted_urls[fqdn][:count] += 1
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
      new_urls += split_urls_as_hashes.map { |split_url| url_type.to_s.classify.constantize.new(split_url) }
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

  def force_related_notices_reindex
    # Force search reindex on related notices
    NoticeUpdateCall.create!(caller_id: self.id, caller_type: 'work') if saved_change_to_description?
  end

  def new_record?
    true
  end

  def valid_url(type, params)
    url_instance = type.new(params)
    if url_instance.valid?
      url_instance
    else
      not_valid_url_return(type)
    end
  rescue ActiveModel::UnknownAttributeError
    not_valid_url_return(type)
  end

  def not_valid_url_return(type)
    type.new(url: 'invalid')
  end

  def filter_urls(url_instances)
    filtered_raw_urls = []
    fqdns = []
    user_allowed = (Current.user && (Current.user.role?(Role.researcher) || Current.user.role?(Role.super_admin)))

    url_instances.each do |url_instance|
      just_url = url_instance.url

      filtered_raw_urls << url_instance and next if SpecialDomain.where('? ~~* domain_name', just_url).where("why_special ? 'full_urls_only_for_researchers'").none? ||
                                                    user_allowed

      fqdn = Work.fqdn_from_url(just_url)

      next if fqdns.include?(fqdn)

      fqdns << fqdn
      url_instance.url = fqdn
      url_instance.only_fqdn = true
      filtered_raw_urls << url_instance
    end

    filtered_raw_urls.uniq
  end
end
