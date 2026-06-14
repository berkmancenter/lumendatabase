class Lumen::WorkUrlRows
  Row = Struct.new(:text, :researchers_only, :url, :full, :fqdn, :count, keyword_init: true)

  def initialize(work:, type:, notice: nil, user: nil)
    @work = work
    @type = type
    @notice = notice
    @user = user
  end

  def rows
    self.class.normalize_collection(url_instances)
  end

  def visible_rows(enterprise_access: nil, bypass_restrictions: false)
    self.class.build_rows(
      url_instances,
      notice: notice,
      user: user,
      enterprise_access: enterprise_access,
      bypass_restrictions: bypass_restrictions
    )
  end

  def limited_rows
    self.class.build_rows(
      url_instances,
      notice: notice,
      user: user,
      limited: true
    )
  end

  def self.enterprise_rows(url_instances, enterprise_access:)
    rows = build_rows(
      url_instances,
      notice: enterprise_access.notice,
      user: enterprise_access.user,
      enterprise_access: enterprise_access
    )
    rows.sort_by { |row| [row.full ? 0 : 1, -(row.count || 1)] }
  end

  def self.normalize(row)
    if row.respond_to?(:text) && row.respond_to?(:researchers_only)
      row
    elsif row.respond_to?(:url)
      Row.new(text: row.url, researchers_only: row.only_fqdn)
    else
      Row.new(
        text: row[:text],
        researchers_only: row[:researchers_only],
        url: row[:url],
        full: row[:full],
        fqdn: row[:fqdn],
        count: row[:count]
      )
    end
  end

  def self.normalize_collection(rows)
    rows.map { |row| normalize(row) }
  end

  class << self
    def build_rows(url_instances, notice:, user:, enterprise_access: nil, limited: false, bypass_restrictions: false)
      lumen_team = bypass_restrictions || user&.role?(:admin) || user&.role?(:super_admin)
      researcher = lumen_team || user&.role?(:researcher)

      # Notice-level restrictions apply uniformly to all URLs in this notice.
      # These come from two sources: the notice flags and notice-granularity content filters.
      notice_lumen_restricted = notice&.restricted_to_lumen_team?
      notice_researchers_restricted = notice&.restricted_to_researchers?

      notice_cf = ContentFilter.notice_filters_matching_notice(notice)
      notice_lumen_filters = notice_cf.select { |f| f.has_action?(:full_notice_version_only_lumen_team) }
      notice_researchers_filters = notice_cf.select { |f| f.has_action?(:full_notice_version_only_researchers) }

      # URL-granularity filters are pre-loaded and matched per URL below.
      url_level_filters = ContentFilter.url_filters_matching_notice(notice)

      grouped = {}
      result = []

      url_instances.each do |url_instance|
        url = url_instance.url.to_s
        url_matching = ContentFilter.matching_url_filters(notice, url_instance, content_filters: url_level_filters)
        url_lumen_filters = url_matching.select { |f| f.has_action?(:full_notice_version_only_lumen_team) }
        url_researchers_filters = url_matching.select { |f| f.has_action?(:full_notice_version_only_researchers) }

        lumen_restricted = notice_lumen_restricted || url_lumen_filters.any?
        researchers_restricted = notice_researchers_restricted || url_researchers_filters.any?
        all_lumen_filters = notice_lumen_filters + url_lumen_filters
        all_researchers_filters = notice_researchers_filters + url_researchers_filters

        if lumen_team
          result << Row.new(text: url, url: url, full: true, researchers_only: false)
        elsif lumen_restricted
          add_grouped(result, grouped, url, all_lumen_filters, researchers_only: false)
        elsif !researcher && researchers_restricted
          add_grouped(result, grouped, url, all_researchers_filters, researchers_only: true)
        elsif enterprise_access&.full_url_visible?(url)
          result << Row.new(text: url, url: url, full: true, researchers_only: false)
        elsif enterprise_access
          add_grouped(result, grouped, url, [], researchers_only: false)
        elsif limited
          add_grouped(result, grouped, url, [], researchers_only: false)
        else
          result << Row.new(text: url, url: url, full: true, researchers_only: url_instance.only_fqdn)
        end
      end

      result.each { |row| row.text ||= "#{row.fqdn} - #{row.count} #{'URL'.pluralize(row.count)}" }
      result
    end

    def add_grouped(result, grouped, url, filters, researchers_only:)
      fqdn = Work.fqdn_from_url(url).presence || url
      fqdn = filters.reduce(fqdn) do |text, filter|
        next text if filter.url_text.blank?
        text.gsub(/#{Regexp.escape(filter.url_text)}/i, Lumen::REDACTION_MASK)
      end
      key = fqdn.downcase

      unless grouped.key?(key)
        grouped[key] = Row.new(fqdn: fqdn, count: 0, full: false, researchers_only: researchers_only)
        result << grouped[key]
      end

      grouped[key].count += 1
    end
  end

  private

  attr_reader :work, :type, :notice, :user

  def url_instances
    work.send("#{type}_urls_public")
  end
end
