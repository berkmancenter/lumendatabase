# frozen_string_literal: true

require 'validates_automatically'

class Work < ActiveRecord::Base
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

  before_save do
    auto_redact

    # DeterminesWorkKind is intended for use here but disabled due to confusion
    # caused by mis-classified works.
    self.kind = 'Unspecified' if kind.blank?

    # Force associated notices to be reindexed if the description has been
    # updated (presumably redacted). This will keep redacted text out of the
    # Elasticsearch index.
    notices.update_all(updated_at: Time.now) if description_changed?
  end
end
