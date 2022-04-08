# frozen_string_literal: true

require 'validates_automatically'

class Work < ApplicationRecord
  include ValidatesAutomatically

  UNKNOWN_WORK_DESCRIPTION = 'Unknown work'.freeze
  REDACTABLE_FIELDS = %w[description].freeze

  has_and_belongs_to_many :notices
  has_and_belongs_to_many :infringing_urls
  has_and_belongs_to_many :copyrighted_urls

  accepts_nested_attributes_for :infringing_urls,
                                :copyrighted_urls,
                                reject_if: proc { |attributes|
                                  attributes['url'].blank?
                                }
  validates_associated :infringing_urls, :copyrighted_urls
  validates :kind, length: { maximum: 255 }

  after_validation :force_redactions
  after_update :force_related_notices_reindex
  before_validation :fix_concatenated_urls, on: :create

  # Similar to the hack in EntityNoticeRole, because all validations are
  # run before all inserts, we have to save to ensure we don't have the
  # same new InfringingUrl or CopyrightedUrl cause a unique key constraint.
  # This means we have to save when validating, and that we could accumulate
  # orphaned *Url model instances.
  %w[infringing_urls copyrighted_urls].each do |relation_type|
    relation_class = relation_type.classify.constantize
    define_method("validate_associated_records_for_#{relation_type}") do
      url_attributes = send(relation_type.to_sym).inject({}) do |memo, url|
        memo.merge(url.url_original =>
                   url.attributes.slice('url', 'url_original'))
      end
      urls_to_associate = url_attributes.keys.compact
      Rails.logger.debug "[importer][works] urls_to_associate: #{urls_to_associate}"

      return if urls_to_associate == ['']

      Rails.logger.debug "[importer][works] new_urls: #{urls_to_associate}"

      new_url_instances = urls_to_associate.map do |url|
        relation_class.new(url_attributes[url])
      end
      failing = new_url_instances.reject(&:valid?)
      relation_class.import new_url_instances, on_duplicate_key_ignore: [:url_original]

      send(
        "#{relation_type}=".to_sym,
        failing + relation_class.where(url_original: urls_to_associate)
      )
    end
  end

  # This is very slow; don't call it directly except at app startup time.
  # config/application.rb stores the result; fetch it from there.
  def self.unknown
    @unknown ||= find_or_create!(
      kind: 'unknown', description: UNKNOWN_WORK_DESCRIPTION
    )
  end

  def self.find_or_create!(attributes)
    where(attributes).first || create!(attributes)
  end

  def infringing_urls_counted_by_domain
    @infringing_urls_counted_by_domain  ||= count_by_domain(infringing_urls)
  end

  def copyrighted_urls_counted_by_domain
    @copyrighted_urls_counted_by_domain ||= count_by_domain(copyrighted_urls)
  end

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

  def auto_redact
    InstanceRedactor.new.redact(self, REDACTABLE_FIELDS)
  end

  def force_redactions
    auto_redact

    # DeterminesWorkKind is intended for use here but disabled due to confusion
    # caused by mis-classified works.
    self.kind = 'Unspecified' if kind.blank?
  end

  def force_related_notices_reindex
    # Force search reindex on related notices
    NoticeUpdateCall.create!(caller_id: self.id, caller_type: 'work') if saved_change_to_description?
  end

  def fix_concatenated_urls
    copyrighted_urls = fixed_urls(:copyrighted_urls)
    infringing_urls = fixed_urls(:infringing_urls)
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
end
