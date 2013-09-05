require 'validates_automatically'

class Work < ActiveRecord::Base
  include ValidatesAutomatically

  has_and_belongs_to_many :notices
  has_and_belongs_to_many :infringing_urls
  has_and_belongs_to_many :copyrighted_urls

  accepts_nested_attributes_for :infringing_urls, :copyrighted_urls

  %w(infringing_urls copyrighted_urls).each do |relation_type|
    relation_class = relation_type.classify.constantize

    define_method("validate_associated_records_for_#{relation_type}") do
      # Similar to the hack in EntityNoticeRole, because all validations are
      # run before all inserts, we have to save to ensure we don't have the
      # same new InfringingUrl or CopyrightedUrl cause a unique key constraint.
      # This means we have to save when validating, and that we could accumulate
      # orphaned *Url model instances.
      self.send(relation_type.to_sym).map! do |instance|
        if existing_url_relation = relation_class.find_by_url(instance.url)
          existing_url_relation
        else
          instance.save
          instance
        end
      end
    end
  end

  before_save do
    if self.kind.blank?
      determiner = DeterminesWorkKind.new(
        copyrighted_urls.map(&:url), infringing_urls.map(&:url)
      )
      self.kind = determiner.kind
    end
  end
end
