require 'lumen/models'
require 'lumen/models/validates_automatically'

class ContentFilter < ApplicationRecord
  include Lumen::Models::ValidatesAutomatically

  QUERY_NOT_EVALUATED = Object.new.freeze

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

  def matches_notice?(notice_instance, query_match: QUERY_NOT_EVALUATED)
    criteria = []
    criteria << resolved_query_match(notice_instance, query_match) if query.present?
    criteria << url_text_matches_notice?(notice_instance) if url_text.present?

    criteria.any? && criteria.all?
  end

  def restricts_user?(user = nil, permissions: nil)
    permissions ||= self.class.user_permissions(user)

    (has_action?(:full_notice_version_only_lumen_team) && !permissions[:lumen_team]) ||
      (has_action?(:full_notice_version_only_researchers) && !permissions[:researcher])
  end

  def self.notice_has_action?(notice_instance, action_id)
    return false unless notice_instance

    match_set_for(notice_instance).notice_has_action?(action_id)
  end

  def self.matching_url_filters(notice_instance, url_instance, content_filters: nil)
    return [] unless notice_instance && url_instance

    return match_set_for(notice_instance).matching_url_filters(url_instance) unless content_filters

    content_filters.select { |content_filter| content_filter.matches_url?(url_instance) }
  end

  def self.url_filters_matching_notice(notice_instance)
    return [] unless notice_instance

    match_set_for(notice_instance).url_filters
  end

  def self.notice_filters_matching_notice(notice_instance)
    return [] unless notice_instance

    match_set_for(notice_instance).notice_filters
  end

  def self.match_set_for(notice_instance)
    return Lumen::ContentFilters::MatchSet.empty unless notice_instance

    context = Current.content_filter_context
    return context.for(notice_instance) if context

    cache_ivar = :@content_filter_match_set
    return notice_instance.instance_variable_get(cache_ivar) if notice_instance.instance_variable_defined?(cache_ivar)

    Lumen::ContentFilters::MatchSet.new(notice_instance, ContentFilter.all.to_a).tap do |match_set|
      notice_instance.instance_variable_set(cache_ivar, match_set)
    end
  end

  def self.query_matches_for(notice_instance, content_filters)
    query_filters = content_filters.select { |content_filter| content_filter.query.present? }
    return {} if query_filters.empty?

    expressions = query_filters.each_with_index.map do |content_filter, index|
      Arel.sql(
        "COALESCE(BOOL_OR(COALESCE((#{content_filter.query}), FALSE)), FALSE) " \
        "AS content_filter_match_#{index}"
      )
    end

    values = Notice
             .includes(:topics, :entity_notice_roles, :entities)
             .where(id: notice_instance.id)
             .references(:topics, :entity_notice_roles, :entities)
             .pick(*expressions)
    values = [values] if query_filters.one?

    query_filters.each_with_index.to_h do |content_filter, index|
      [content_filter.id, values&.fetch(index, false) == true]
    end
  end

  def self.user_permissions(user)
    lumen_team = user&.role?(:admin) || user&.role?(:super_admin)

    {
      lumen_team: lumen_team,
      researcher: lumen_team || user&.role?(:researcher)
    }
  end

  def matches_notice_query?(notice_instance, query_match: QUERY_NOT_EVALUATED)
    query.blank? || resolved_query_match(notice_instance, query_match)
  end

  def matches_url?(url_instance)
    return false if url_text.blank?

    url_text_needle = url_text.downcase

    url_text_candidates(url_instance).any? do |url_text_candidate|
      url_text_candidate.downcase.include?(url_text_needle)
    end
  end

  private

  def resolved_query_match(notice_instance, query_match)
    return query_matches_notice?(notice_instance) if query_match.equal?(QUERY_NOT_EVALUATED)

    query_match
  end

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
