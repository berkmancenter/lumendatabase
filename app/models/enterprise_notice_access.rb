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
      enterprise_account.active? &&
      enterprise_domains.any? &&
      !restricted_notice? &&
      matching_infringing_urls.any?
  end

  def matching_infringing_urls
    return [] unless notice

    notice.works.flat_map(&:infringing_urls).select do |url|
      EnterpriseDomain.matches_url?(url.url, enterprise_domains)
    end
  end

  def url_rows(url_instances)
    grouped_rows = {}
    rows = []

    url_instances.each do |url_instance|
      url = url_instance.url.to_s

      if EnterpriseDomain.matches_url?(url, enterprise_domains)
        rows << {
          text: url,
          url: url,
          full: true,
          only_fqdn: false
        }
      else
        fqdn = Work.fqdn_from_url(url).presence || url
        key = fqdn.downcase

        unless grouped_rows.key?(key)
          grouped_rows[key] = {
            fqdn: fqdn,
            count: 0,
            full: false,
            only_fqdn: false
          }
          rows << grouped_rows[key]
        end

        grouped_rows[key][:count] += 1
      end
    end

    rows.sort_by { |row| [row[:full] ? 0 : 1, -(row[:count] || 1)] }.map do |row|
      row[:text] ||= "#{row[:fqdn]} - #{row[:count]} #{'URL'.pluralize(row[:count])}"
      row
    end
  end

  def serialized_urls(url_instances)
    url_rows(url_instances).map do |row|
      if row[:full]
        { url: row[:url] }
      else
        { fqdn: row[:fqdn], count: row[:count] }
      end
    end
  end

  private

  def enterprise_account
    return @enterprise_account if @enterprise_account.present?
    return unless enterprise_user?

    @enterprise_account = user.enterprise_account
  end

  def enterprise_user?
    user&.role?(Role.enterprise)
  end

  def enterprise_domains
    @enterprise_domains ||= enterprise_account&.verified_domain_names || []
  end

  def restricted_notice?
    notice.restricted_to_researchers? ||
      ContentFilter.notice_has_action?(notice, :full_notice_version_only_lumen_team)
  end
end
