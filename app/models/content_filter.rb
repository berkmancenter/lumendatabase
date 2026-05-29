require 'validates_automatically'

class ContentFilter < ApplicationRecord
  include ValidatesAutomatically

  validates :name, presence: true
  validates :granularity, inclusion: { in: %w[notice urls] }
  validate :query_or_url_text_present

  before_validation :normalize_url_text
  before_validation :set_default_granularity

  def actions_enum
    [
      ['Full notice version only for Lumen team', :full_notice_version_only_lumen_team],
      ['Full notice version only for researchers', :full_notice_version_only_researchers]
    ]
  end

  def granularity_enum
    [
      ['Notice', 'notice'],
      ['URLs', 'urls']
    ]
  end

  def has_action?(action_id)
    actions.to_a.any? { |action| action.to_sym == action_id }
  end

  def notice_granularity?
    granularity == 'notice'
  end

  def urls_granularity?
    granularity == 'urls'
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
      next unless content_filter.notice_granularity?
      next unless content_filter.matches_notice?(notice_instance)

      return true if content_filter.has_action?(action_id)
    end

    false
  end

  def self.url_restricted?(notice_instance, url_instance, user = nil, content_filters: nil, permissions: nil)
    url_action(
      notice_instance,
      url_instance,
      user,
      content_filters: content_filters,
      permissions: permissions
    ) != :visible
  end

  def self.url_hidden?(notice_instance, url_instance, user = nil, content_filters: nil, permissions: nil)
    url_action(
      notice_instance,
      url_instance,
      user,
      content_filters: content_filters,
      permissions: permissions
    ) == :hidden
  end

  def self.url_action(notice_instance, url_instance, user = nil, content_filters: nil, permissions: nil)
    matching_filters = matching_url_filters(
      notice_instance,
      url_instance,
      content_filters: content_filters
    )
    permissions ||= user_permissions(user)

    return :hidden if matching_filters.any? do |content_filter|
      content_filter.hides_url_from_user?(permissions: permissions)
    end
    return :restricted if matching_filters.any? do |content_filter|
      content_filter.redacts_url_from_user?(permissions: permissions)
    end

    :visible
  end

  def self.matching_url_filters(notice_instance, url_instance, content_filters: nil)
    return [] unless notice_instance && url_instance

    (content_filters || url_filters_matching_notice(notice_instance)).select do |content_filter|
      content_filter.matches_url?(url_instance)
    end
  end

  def self.url_filters_matching_notice(notice_instance)
    return [] unless notice_instance

    ContentFilter.where(granularity: 'urls').select do |content_filter|
      content_filter.matches_notice_query?(notice_instance)
    end
  end

  def self.user_permissions(user)
    lumen_team = user&.role?(:admin) || user&.role?(:super_admin)

    {
      lumen_team: lumen_team,
      researcher: lumen_team || user&.role?(:researcher)
    }
  end

  def restricts_user?(user, permissions: nil)
    permissions ||= self.class.user_permissions(user)

    hides_url_from_user?(permissions: permissions) ||
      redacts_url_from_user?(permissions: permissions)
  end

  def hides_url_from_user?(user = nil, permissions: nil)
    permissions ||= self.class.user_permissions(user)

    (
      has_action?(:full_notice_version_only_lumen_team) &&
        !permissions[:lumen_team]
    )
  end

  def redacts_url_from_user?(user = nil, permissions: nil)
    permissions ||= self.class.user_permissions(user)

    has_action?(:full_notice_version_only_researchers) &&
      !permissions[:researcher]
  end

  def matches_notice_query?(notice_instance)
    query.blank? || query_matches_notice?(notice_instance)
  end

  def matches_url?(url_instance)
    return false if url_text.blank?

    url_text_needle = url_text.downcase

    url_text_candidates(url_instance).any? do |url_text_candidate|
      url_text_candidate.downcase.include?(url_text_needle)
    end
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
    notice_urls(notice_instance).any? do |url|
      matches_url?(url)
    end
  end

  def url_text_candidates(url_instance)
    [url_instance.url, url_instance.url_original].compact
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

  def set_default_granularity
    self.granularity = 'notice' if granularity.blank?
  end

end
