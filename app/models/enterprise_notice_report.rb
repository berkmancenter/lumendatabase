class EnterpriseNoticeReport
  attr_reader :enterprise_account, :starts_at, :ends_at

  def initialize(enterprise_account, starts_at:, ends_at: Time.current)
    @enterprise_account = enterprise_account
    @starts_at = starts_at
    @ends_at = ends_at
  end

  def self.recent(enterprise_account, limit: 5)
    Notice
      .visible
      .order(created_at: :desc)
      .limit(500)
      .select { |notice| EnterpriseNoticeAccess.for_account(enterprise_account, notice).allowed? }
      .first(limit)
  end

  def notices
    @notices ||= begin
      scope = Notice.visible.order(created_at: :desc)
      scope = scope.where(created_at: starts_at..ends_at) if starts_at.present?

      scope.select do |notice|
        EnterpriseNoticeAccess.for_account(enterprise_account, notice).allowed?
      end
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
    access = EnterpriseNoticeAccess.for_account(enterprise_account, notice)

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
end
