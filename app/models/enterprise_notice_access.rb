class EnterpriseNoticeAccess
  attr_reader :notice, :user

  def self.allowed?(user, notice)
    new(user, notice).allowed?
  end

  def self.for_account(account, notice)
    new(nil, notice, enterprise_account: account)
  end

  def initialize(user, notice, enterprise_account: nil)
    @user = user
    @notice = notice
    @enterprise_account = enterprise_account
  end

  def allowed?
    enterprise_account.present? &&
      enterprise_account.pro? &&
      enterprise_domains.any? &&
      !restricted_notice? &&
      matching_infringing_urls.any?
  end

  def matching_infringing_urls
    return [] unless notice

    notice.works.flat_map(&:infringing_urls).select do |url|
      full_url_visible?(url.url)
    end
  end

  def url_rows(url_instances)
    WorkUrlRows.enterprise_rows(url_instances, enterprise_access: self)
  end

  def serialized_urls(url_instances)
    url_rows(url_instances).map do |row|
      if row.full
        { url: row.url }
      else
        { fqdn: row.fqdn, count: row.count }
      end
    end
  end

  def full_url_visible?(url)
    EnterpriseDomain.matches_url?(url.to_s, enterprise_domains)
  end

  private

  def enterprise_account
    return @enterprise_account if @enterprise_account.present?
    return unless enterprise_user?

    @enterprise_account = user.enterprise_account
  end

  def enterprise_user?
    user&.role?(:enterprise)
  end

  def enterprise_domains
    @enterprise_domains ||= enterprise_account&.verified_domain_names || []
  end

  def restricted_notice?
    notice.restricted_to_researchers? ||
      notice.restricted_to_lumen_team?
  end
end
