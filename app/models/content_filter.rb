require 'validates_automatically'

class ContentFilter < ApplicationRecord
  include ValidatesAutomatically

  validates :name, presence: true
  validates :query, presence: true

  def actions_enum
    [
      ['Full notice version only for Lumen team', :full_notice_version_only_lumen_team],
      ['Full notice version only for researchers', :full_notice_version_only_researchers]
    ]
  end

  def has_action?(action_id)
    actions.select { |action| action.to_sym == action_id }.any?
  end

  def self.notice_has_action?(notice_instance, action_id)
    ContentFilter.all.each do |content_filter|
      next unless Notice.includes(:topics)
                        .includes(:entity_notice_roles)
                        .includes(:entities)
                        .where(id: notice_instance.id)
                        .where(content_filter.query)
                        .references(:topics)
                        .references(:entity_notice_roles)
                        .references(:entities)
                        .any?

      return true if content_filter.has_action?(action_id)
    end

    false
  end
end
