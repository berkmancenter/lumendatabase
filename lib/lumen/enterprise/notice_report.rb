class Lumen::Enterprise::NoticeReport
  SEARCH_BATCH_SIZE = 1_000

  attr_reader :enterprise_account, :starts_at, :ends_at

  def initialize(enterprise_account, starts_at:, ends_at: Time.current)
    @enterprise_account = enterprise_account
    @starts_at = starts_at
    @ends_at = ends_at
  end

  def self.recent(enterprise_account, limit: 5)
    new(enterprise_account, starts_at: nil).notices(limit: limit)
  end

  def notices(limit: nil)
    return @notices if limit.nil? && defined?(@notices)

    matching_notices(limit: limit).tap do |result|
      @notices = result if limit.nil?
    end
  end

  def as_json(*)
    {
      enterprise_account: {
        id: enterprise_account.id,
        name: enterprise_account.name,
        domains: enterprise_account.verified_domain_names
      },
      period: {
        starts_at: starts_at,
        ends_at: ends_at
      },
      notices: notices.map { |notice| notice_json(notice) }
    }
  end

  private

  def notice_json(notice)
    access = access_for(notice)

    {
      id: notice.id,
      title: notice.title,
      type: notice.type,
      date_received: notice.date_received,
      date_submitted: notice.created_at,
      sender_name: notice.sender_name,
      principal_name: notice.principal_name,
      recipient_name: notice.recipient_name,
      submitter_name: notice.submitter_name,
      matching_infringing_urls: access.matching_infringing_urls.map(&:url)
    }
  end

  def matching_notices(limit:)
    return [] unless searchable?

    matches = []

    each_candidate_notice_batch do |candidate_notices|
      candidate_notices.each do |notice|
        next unless candidate_reportable?(notice)
        next unless access_for(notice).allowed?

        matches << notice
        return matches if limit && matches.size >= limit
      end
    end

    matches
  end

  def each_candidate_notice_batch
    search_after = nil

    loop do
      hits = notice_search_hits(search_after: search_after)
      break if hits.empty?

      yield candidate_notices(search_hit_ids(hits))

      search_after = hits.last['sort']
      break if search_after.blank?
      break if hits.size < SEARCH_BATCH_SIZE
    end
  end

  def notice_search_hits(search_after:)
    Notice
      .__elasticsearch__
      .client
      .search(
        index: Notice.__elasticsearch__.index_name,
        body: search_body(search_after: search_after)
      )
      .dig('hits', 'hits') || []
  end

  def search_body(search_after:)
    {
      _source: ['id'],
      size: SEARCH_BATCH_SIZE,
      track_total_hits: false,
      query: {
        bool: {
          filter: search_filters
        }
      },
      sort: [
        { created_at: { order: 'desc' } },
        { id: { order: 'desc' } }
      ]
    }.tap do |body|
      body[:search_after] = search_after if search_after.present?
    end
  end

  def search_filters
    visible_filters + domain_filters + date_filters
  end

  def visible_filters
    Notice.visible_qualifiers.map do |field, value|
      { term: { field => value } }
    end
  end

  def domain_filters
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
    range = {}
    range[:gte] = starts_at.iso8601 if starts_at.present?
    range[:lte] = ends_at.iso8601 if ends_at.present?

    return [] if range.empty?

    [{ range: { created_at: range } }]
  end

  def search_hit_ids(hits)
    hits.map { |hit| hit.dig('_source', 'id') || hit['_id'] }
  end

  def candidate_notices(ids)
    notices_by_id = Notice
                    .includes(:entity_notice_roles, :entities)
                    .where(id: ids)
                    .index_by { |notice| notice.id.to_s }

    ids.filter_map { |id| notices_by_id[id.to_s] }
  end

  def searchable?
    enterprise_account&.pro? && enterprise_domain_names.any?
  end

  def candidate_reportable?(notice)
    visible?(notice) && within_report_period?(notice)
  end

  def visible?(notice)
    Notice.visible_qualifiers.all? do |attribute, value|
      notice.public_send(attribute) == value
    end
  end

  def within_report_period?(notice)
    return false if starts_at.present? && notice.created_at < starts_at
    return false if ends_at.present? && notice.created_at > ends_at

    true
  end

  def enterprise_domain_names
    @enterprise_domain_names ||= enterprise_account&.verified_domain_names || []
  end

  def access_for(notice)
    Lumen::Enterprise::NoticeAccess.for_account(
      enterprise_account,
      notice,
      enterprise_domains: enterprise_domain_names
    )
  end
end
