require 'validates_automatically'

class Work < ActiveRecord::Base
  include ValidatesAutomatically

  UNKNOWN_WORK_DESCRIPTION = "Unknown work"

  has_and_belongs_to_many :notices
  has_and_belongs_to_many :infringing_urls
  has_and_belongs_to_many :copyrighted_urls

  accepts_nested_attributes_for :infringing_urls, :copyrighted_urls, :reject_if => proc { |attributes| attributes['url'].blank? }
  validates_associated :infringing_urls, :copyrighted_urls
  validates :kind, length: { maximum: 255 }

  # Similar to the hack in EntityNoticeRole, because all validations are
  # run before all inserts, we have to save to ensure we don't have the
  # same new InfringingUrl or CopyrightedUrl cause a unique key constraint.
  # This means we have to save when validating, and that we could accumulate
  # orphaned *Url model instances.
  %w(infringing_urls copyrighted_urls).each do |relation_type|
    relation_class = relation_type.classify.constantize
    define_method("validate_associated_records_for_#{relation_type}") do
      url_attributes =  send(relation_type.to_sym).inject({}) do |memo, url|
        memo.merge(url.url_original => url.attributes.slice("url", "url_original"))
      end
      urls_to_associate = url_attributes.keys.compact
      Rails.logger.debug "[importer][works] urls_to_associate: #{urls_to_associate}"

      return if urls_to_associate == ['']

      existing_url_instances = relation_class.where(url_original: urls_to_associate)
      existing_urls = existing_url_instances.map(&:url_original)
      Rails.logger.debug "[importer][works] existing_urls: #{existing_urls}"

      new_urls = urls_to_associate - existing_urls
      Rails.logger.debug "[importer][works] new_urls: #{new_urls}"

      new_url_instances = new_urls.map { |url| relation_class.new(url_attributes[url]) }
      failing = new_url_instances.reject(&:valid?)
      relation_class.import new_url_instances

      existing_url_instances.each do |url|
        atts = url_attributes[url.url_original]
        if atts["url"].present? && atts["url"] != atts["url_original"]
          url.update_attributes!(url: atts["url"]) if atts["url"] != url.url
        end
      end

      send(
        "#{relation_type}=".to_sym,
        existing_url_instances + failing + relation_class.where(url_original: new_urls)
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

# Code below is to run a basic classifier for work kinds. Disabled due to confusion caused by mis-classified works.
  before_save do
    if kind.blank?
      self.kind = 'Unspecified' #DeterminesWorkKind.new(self).kind
    end
  end

  before_save on: :create do
    self.description_original = description if self.description_original.nil?
  end
end
