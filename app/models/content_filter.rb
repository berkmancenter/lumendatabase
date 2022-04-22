require 'validates_automatically'

class ContentFilter < ApplicationRecord
  include ValidatesAutomatically

  validates :name, presence: true
  validates :query, presence: true

  serialize :actions, Array

  def actions_enum
    [
      ['Full notice version only for Lumen team', :full_notice_version_only_lumen_team]
    ]
  end

  def has_action?(action_id)
    actions.select { |action| action.to_sym == action_id }.any?
  end

  def self.notice_has_action?(notice_instance, action_id)
    ContentFilter.all.each do |content_filter|
      next unless Notice.joins(works: [:infringing_urls, :copyrighted_urls])
                        .joins(:topics)
                        .joins(entity_notice_roles: :entity)
                        .joins(tags: :taggings)
                        .joins(jurisdictions: :taggings)
                        .joins(:entities)
                        .where(id: notice_instance.id)
                        .where(content_filter.query)
                        .any?

      return true if content_filter.has_action?(action_id)
    end

    false
  end
end
