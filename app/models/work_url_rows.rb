class WorkUrlRows
  Row = Struct.new(:text, :only_fqdn, :url, :full, :fqdn, :count, keyword_init: true)

  def initialize(work:, type:, notice: nil, user: nil)
    @work = work
    @type = type
    @notice = notice
    @user = user
  end

  def rows
    self.class.normalize_collection(url_instances)
  end

  def content_filter_rows
    rows = []
    grouped_rows = {}

    url_instances.each do |url_instance|
      matching_filters = ContentFilter.matching_url_filters(
        notice,
        url_instance,
        content_filters: content_filters
      )

      case ContentFilter.url_action(
        notice,
        url_instance,
        user,
        content_filters: matching_filters,
        permissions: user_permissions
      )
      when :hidden
        next
      when :restricted
        add_grouped_row(rows, grouped_rows, url_instance.url)
      else
        if lumen_team_filtered_for_admin?(matching_filters)
          add_grouped_row(
            rows,
            grouped_rows,
            url_instance.url,
            redaction_filters: matching_filters
          )
        else
          rows << {
            text: url_instance.url,
            only_fqdn: url_instance.only_fqdn
          }
        end
      end
    end

    rows.map do |row|
      row[:text] ||= "#{row[:fqdn]} - #{row[:count]} #{'URL'.pluralize(row[:count])}"
      self.class.normalize(row)
    end
  end

  def enterprise_rows(enterprise_access:)
    self.class.enterprise_rows(url_instances, enterprise_access: enterprise_access)
  end

  def self.enterprise_rows(url_instances, enterprise_access:)
    rows = []
    grouped_rows = {}

    url_instances.each do |url_instance|
      url = url_instance.url.to_s

      if enterprise_access.full_url_visible?(url)
        rows << Row.new(
          text: url,
          url: url,
          full: true,
          only_fqdn: false
        )
      else
        fqdn = Work.fqdn_from_url(url).presence || url
        key = fqdn.downcase

        unless grouped_rows.key?(key)
          grouped_rows[key] = Row.new(
            fqdn: fqdn,
            count: 0,
            full: false,
            only_fqdn: false
          )
          rows << grouped_rows[key]
        end

        grouped_rows[key].count += 1
      end
    end

    rows.sort_by { |row| [row.full ? 0 : 1, -(row.count || 1)] }.map do |row|
      row.text ||= "#{row.fqdn} - #{row.count} #{'URL'.pluralize(row.count)}"
      row
    end
  end

  def self.normalize(row)
    if row.respond_to?(:text) && row.respond_to?(:only_fqdn)
      row
    elsif row.respond_to?(:url)
      Row.new(text: row.url, only_fqdn: row.only_fqdn)
    else
      Row.new(
        text: row[:text],
        only_fqdn: row[:only_fqdn],
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

  private

  attr_reader :work, :type, :notice, :user

  def url_instances
    work.send("#{type}_urls_public")
  end

  def content_filters
    @content_filters ||= ContentFilter.url_filters_matching_notice(notice)
  end

  def user_permissions
    @user_permissions ||= ContentFilter.user_permissions(user)
  end

  def add_grouped_row(rows, grouped_rows, url, redaction_filters: [])
    fqdn = Work.fqdn_from_url(url).presence || url
    fqdn = redact_fqdn_filter_text(fqdn, redaction_filters)
    key = fqdn.downcase

    unless grouped_rows.key?(key)
      grouped_rows[key] = {
        fqdn: fqdn,
        count: 0,
        only_fqdn: true
      }
      rows << grouped_rows[key]
    end

    grouped_rows[key][:count] += 1
  end

  def lumen_team_filtered_for_admin?(matching_filters)
    user_permissions[:lumen_team] &&
      matching_filters.any? { |content_filter| content_filter.has_action?(:full_notice_version_only_lumen_team) }
  end

  def redact_fqdn_filter_text(fqdn, filters)
    filters.reduce(fqdn) do |redacted_fqdn, content_filter|
      next redacted_fqdn unless content_filter.has_action?(:full_notice_version_only_lumen_team)
      next redacted_fqdn if content_filter.url_text.blank?

      redacted_fqdn.gsub(/#{Regexp.escape(content_filter.url_text)}/i, '[REDACTED]')
    end
  end
end
