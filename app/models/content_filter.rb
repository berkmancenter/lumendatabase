require 'validates_automatically'

class ContentFilter < ApplicationRecord
  include ValidatesAutomatically

  validates :name, presence: true
  validate :query_or_url_text_present

  before_validation :normalize_url_text

  def actions_enum
    [
      ['Full notice version only for Lumen team', :full_notice_version_only_lumen_team],
      ['Full notice version only for researchers', :full_notice_version_only_researchers]
    ]
  end

  def has_action?(action_id)
    actions.to_a.any? { |action| action.to_sym == action_id }
  end

  def matches_notice?(notice_instance)
    criteria = []
    criteria << query_matches_notice?(notice_instance) if query.present?
    criteria << url_text_matches_notice?(notice_instance) if url_text.present?

    criteria.any? && criteria.all?
  end

  def self.notice_has_action?(notice_instance, action_id)
    return false unless notice_instance

    ContentFilter.all.each do |content_filter|
      next unless content_filter.matches_notice?(notice_instance)

      return true if content_filter.has_action?(action_id)
    end

    false
  end

  private

  def query_matches_notice?(notice_instance)
    Notice.includes(:topics)
          .includes(:entity_notice_roles)
          .includes(:entities)
          .where(id: notice_instance.id)
          .where(query)
          .references(:topics)
          .references(:entity_notice_roles)
          .references(:entities)
          .any?
  end

  def url_text_matches_notice?(notice_instance)
    url_text_needle = url_text.downcase

    notice_urls(notice_instance).any? do |url|
      [url.url, url.url_original].compact.any? do |url_text_candidate|
        url_text_candidate.downcase.include?(url_text_needle)
      end
    end
  end

  def notice_urls(notice_instance)
    notice_instance.works.to_a.flat_map do |work|
      work.infringing_urls + work.copyrighted_urls
    end
  end

  def query_or_url_text_present
    return if query.present? || url_text.present?

    errors.add(:base, 'Query or URL text must be present')
  end

  def normalize_url_text
    self.url_text = url_text&.strip
  end
end
