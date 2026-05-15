require 'validates_automatically'

class ContentFilter < ApplicationRecord
  include ValidatesAutomatically

  validates :name, presence: true
  validates :query, presence: true, unless: -> { url_text.present? }
  validates :url_text, presence: true, unless: -> { query.present? }

  def actions_enum
    [
      ['Full notice version only for Lumen team', :full_notice_version_only_lumen_team],
      ['Full notice version only for researchers', :full_notice_version_only_researchers]
    ]
  end

  def has_action?(action_id)
    Array(actions).select { |action| action.to_sym == action_id }.any?
  end

  def matches_notice?(notice_instance)
    scope = Notice.includes(:topics)
                  .includes(:entity_notice_roles)
                  .includes(:entities)
                  .where(id: notice_instance.id)

    scope = scope.where(query) if query.present?
    scope = scope.where(url_text_filter_query, url_text_pattern: "%#{sanitize_sql_like(url_text)}%") if url_text.present?

    scope.references(:topics)
         .references(:entity_notice_roles)
         .references(:entities)
         .any?
  end

  def self.notice_has_action?(notice_instance, action_id)
    ContentFilter.all.each do |content_filter|
      next unless content_filter.matches_notice?(notice_instance)

      return true if content_filter.has_action?(action_id)
    end

    false
  end

  private

  def sanitize_sql_like(value)
    ActiveRecord::Base.sanitize_sql_like(value)
  end

  def url_text_filter_query
    <<~SQL.squish
      EXISTS (
        SELECT 1
        FROM jsonb_array_elements(COALESCE(notices.works_json, '[]'::jsonb)) AS work(work_json)
        CROSS JOIN LATERAL (
          SELECT infringing_url.url_json
          FROM jsonb_array_elements(COALESCE(work.work_json->'infringing_urls', '[]'::jsonb)) AS infringing_url(url_json)
          UNION ALL
          SELECT copyrighted_url.url_json
          FROM jsonb_array_elements(COALESCE(work.work_json->'copyrighted_urls', '[]'::jsonb)) AS copyrighted_url(url_json)
        ) AS notice_urls(url_json)
        WHERE
          notice_urls.url_json->>'url' ILIKE :url_text_pattern OR
          notice_urls.url_json->>'url_original' ILIKE :url_text_pattern
      )
    SQL
  end
end
