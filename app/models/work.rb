require 'validates_automatically'

class Work < ActiveRecord::Base
  include ValidatesAutomatically

  UNKNOWN_WORK_DESCRIPTION = "Unknown work"

  has_and_belongs_to_many :notices
  has_and_belongs_to_many :infringing_urls
  has_and_belongs_to_many :copyrighted_urls

  accepts_nested_attributes_for :infringing_urls, :copyrighted_urls
  validates_associated :infringing_urls, :copyrighted_urls

  # Similar to the hack in EntityNoticeRole, because all validations are
  # run before all inserts, we have to save to ensure we don't have the
  # same new InfringingUrl or CopyrightedUrl cause a unique key constraint.
  # This means we have to save when validating, and that we could accumulate
  # orphaned *Url model instances.
  %w(infringing_urls copyrighted_urls).each do |relation_type|
    relation_class = relation_type.classify.constantize
    define_method("validate_associated_records_for_#{relation_type}") do
      urls_to_associate = send(relation_type.to_sym).map(&:url).uniq.compact

      return if urls_to_associate == ['']

      existing_url_instances = relation_class.where(url: urls_to_associate)
      existing_urls = existing_url_instances.map(&:url)

      new_urls = urls_to_associate - existing_urls
      new_url_instances = new_urls.map { |url| relation_class.new(url: url) }
      relation_class.import new_url_instances

      send(
        "#{relation_type}=".to_sym,
        existing_url_instances + relation_class.where(url: new_urls)
      )
    end
  end

  def self.unknown
    @unknown ||= find_or_create!(
      kind: :unknown, description: UNKNOWN_WORK_DESCRIPTION
    )
  end

  def self.find_or_create!(attributes)
    where(attributes).first || create!(attributes)
  end

  before_save do
    if kind.blank?
      self.kind = DeterminesWorkKind.new(self).kind
    end
  end
end
