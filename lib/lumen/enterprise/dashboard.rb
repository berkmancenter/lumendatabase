require 'digest'

class Lumen::Enterprise::Dashboard
  PERIOD_DAYS = 30
  RECENT_NOTICE_LIMIT = 5
  RECENT_CANDIDATE_LIMIT = 50
  CACHE_TTL = 2.minutes
  CACHE_VERSION = 1

  attr_reader :enterprise_account, :now

  def initialize(enterprise_account, now: Time.current)
    @enterprise_account = enterprise_account
    @now = now
  end

  def total_notices
    load_summary
    activity_buckets.values.sum
  end

  def notices_last_seven_days
    daily_activity
      .select { |date, _count| date >= 6.days.ago(now).to_date }
      .values
      .sum
  end

  def daily_activity
    load_summary

    period_dates.index_with { 0 }.merge(activity_buckets)
  end

  def notice_types
    load_summary

    Array(summary_response.dig('aggregations', 'notice_types', 'buckets')).to_h do |bucket|
      [type_label(bucket['key']), bucket['doc_count'].to_i]
    end
  end

  def recent_notices
    load_summary

    @recent_notices ||= candidate_notices(recent_notice_ids)
                        .select { |notice| candidate_reportable?(notice) }
                        .first(RECENT_NOTICE_LIMIT)
  end

  def matching_url_count(notice)
    access_for(notice).matching_infringing_urls.size
  end

  private

  attr_reader :summary_response

  def load_summary
    return if defined?(@summary_response)

    @summary_response = searchable? ? search_summary : empty_response
  end

  def search_summary
    Rails.cache.fetch(summary_cache_key, expires_in: CACHE_TTL) do
      Notice.__elasticsearch__.client.search(
        index: Notice.__elasticsearch__.index_name,
        body: summary_search_body
      )
    end
  end

  def summary_search_body
    {
      _source: false,
      size: RECENT_CANDIDATE_LIMIT,
      track_total_hits: false,
      query: {
        bool: {
          filter: visible_filters + domain_filters + date_filters
        }
      },
      sort: [
        { created_at: { order: 'desc' } },
        { id: { order: 'desc' } }
      ],
      aggs: {
        daily_notices: {
          date_histogram: {
            field: 'created_at',
            calendar_interval: 'day',
            format: 'yyyy-MM-dd',
            min_doc_count: 0,
            extended_bounds: {
              min: period_start.to_date.iso8601,
              max: now.to_date.iso8601
            }
          }
        },
        notice_types: {
          terms: {
            field: 'class_name',
            size: 6
          }
        }
      }
    }
  end

  def summary_cache_key
    domain_signature = Digest::SHA256.hexdigest(
      enterprise_domain_names.sort.join("\0")
    )
    time_bucket = now.to_i / CACHE_TTL.to_i

    [
      'enterprise-dashboard',
      CACHE_VERSION,
      enterprise_account.id,
      domain_signature,
      time_bucket
    ]
  end

  def activity_buckets
    Array(summary_response.dig('aggregations', 'daily_notices', 'buckets')).to_h do |bucket|
      [Date.iso8601(bucket['key_as_string']), bucket['doc_count'].to_i]
    end
  end

  def period_dates
    (period_start.to_date..now.to_date).to_a
  end

  def period_start
    @period_start ||= (PERIOD_DAYS - 1).days.ago(now).beginning_of_day
  end

  def recent_notice_ids
    Array(summary_response.dig('hits', 'hits')).filter_map do |hit|
      hit.dig('_source', 'id') || hit['_id']
    end
  end

  def candidate_notices(ids)
    return [] if ids.empty?

    notices_by_id = Notice
                    .includes(:entity_notice_roles, :entities)
                    .where(id: ids)
                    .index_by { |notice| notice.id.to_s }

    ids.filter_map { |id| notices_by_id[id.to_s] }
  end

  def candidate_reportable?(notice)
    visible?(notice) && within_period?(notice) && access_for(notice).allowed?
  end

  def visible?(notice)
    Notice.visible_qualifiers.all? do |attribute, value|
      notice.public_send(attribute) == value
    end
  end

  def within_period?(notice)
    notice.created_at >= period_start && notice.created_at <= now
  end

  def visible_filters
    Notice.visible_qualifiers.map do |field, value|
      { term: { field => value } }
    end
  end

  def domain_filters
    return [{ term: { id: '__no_enterprise_domains__' } }] if enterprise_domain_names.empty?

    [
      {
        bool: {
          should: enterprise_domain_names.map do |domain|
            { match_phrase: { 'works.infringing_urls.url': domain } }
          end,
          minimum_should_match: 1
        }
      }
    ]
  end

  def date_filters
    [
      {
        range: {
          created_at: {
            gte: period_start.iso8601,
            lte: now.iso8601
          }
        }
      }
    ]
  end

  def enterprise_domain_names
    @enterprise_domain_names ||= enterprise_account.verified_domain_names
  end

  def searchable?
    enterprise_account.pro? && enterprise_domain_names.any?
  end

  def access_for(notice)
    @notice_access ||= {}
    @notice_access[notice.id] ||= Lumen::Enterprise::NoticeAccess.for_account(
      enterprise_account,
      notice,
      enterprise_domains: enterprise_domain_names
    )
  end

  def type_label(value)
    return 'DMCA' if value == 'DMCA'

    value.to_s.underscore.humanize
  end

  def empty_response
    {
      'hits' => { 'hits' => [] },
      'aggregations' => {
        'daily_notices' => { 'buckets' => [] },
        'notice_types' => { 'buckets' => [] }
      }
    }
  end
end
