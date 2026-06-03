module NoticesHelper
  # Determines whether 'click to request access' should be an option.
  # Yes, the messy function signature implies there is a lot going on with the
  # business logic.
  def access_requestable?(notice, show_copyrighted, show_infringing)
    [
      show_copyrighted || show_infringing,
      # Additional access cannot be requested for confidential court orders
      # as there is nothing further to display.
      !confidential_order?(notice),
      !notice&.restricted_to_lumen_team?,
      !notice&.restricted_to_researchers?
    ].all?
  end

  def access_just_for_researchers?(notice)
    notice&.restricted_to_researchers?
  end

  def access_just_for_specific_researchers?(notice)
    notice&.submitter&.full_notice_only_researchers_users&.any?
  end

  def researchers_only_notice_message(notice)
    unless notice&.submitter&.full_notice_only_researchers
      return 'The full version of this notice is viewable only by users with a Lumen researcher credential.'
    end

    key =
      if access_just_for_specific_researchers?(notice)
        'notice_show_works_only_for_selected_researchers'
      else
        'notice_show_works_only_for_researchers'
      end

    format(
      Translation.t(key),
      submitter_name: h(notice&.submitter&.name.presence || 'unknown')
    ).html_safe
  end

  def form_partial_for(instance)
    "#{instance.class.name.tableize.singularize}_form"
  end

  def show_partial_for(instance)
    "#{instance.class.name.tableize.singularize}_show"
  end

  def works_partial_for(instance)
    "#{instance.class.name.tableize.singularize}_works"
  end

  def date_sent(notice)
    display_date_field(notice, :date_sent)
  end

  def date_received(notice)
    display_date_field(notice, :date_received)
  end

  def date_submitted(notice)
    display_date_field(notice, :created_at)
  end

  def subject(notice)
    if notice.subject.present?
      notice.subject
    else
      'Unknown'
    end
  end

  def first_time_visitor_content
    MarkdownParser.render(Translation.t('first_time_visitor'))
  end

  def label_for_url_input(url_type, notice)
    case url_type
    when :infringing_urls
      infringing_url_label(notice)
    when :copyrighted_urls
      copyrighted_url_label(notice)
    else
      raise "Unknown url_type: #{url_type}"
    end
  end

  def permanent_url_full_notice(notice)
    token_url = permanent_token_url(notice)

    if token_url
      return notice_url(
        notice,
        access_token: token_url.token,
        host: Chill::Application.config.site_host
      )
    end

    false
  end

  def receive_document_notifications(notice, current_user)
    DocumentNotificationEmail
      .where(
        notice: notice,
        email_address: current_user.email,
        status: 1,
      )
      .any?
  end

  def redact_url_paths(text, unredacted_domains: [])
    text.to_s.gsub(%r{\bhttps?://[^\s<>"']+}i) do |url|
      trailing_punctuation = url[/[.,;:!?)]*\z/]
      clean_url = url.delete_suffix(trailing_punctuation)

      visible_url =
        if unredacted_url_path?(clean_url, unredacted_domains)
          clean_url
        else
          redact_url_path(clean_url)
        end

      visible_url + trailing_punctuation
    end
  end

  def redact_url_paths_unless_full_notice(notice, text)
    return text if can_see_full_notice_version?(notice)

    redact_url_paths(text)
  end

  def enterprise_url_rows(work, type, notice)
    url_instances = work.send("#{type}_urls_public")
    EnterpriseNoticeAccess.new(current_user, notice).url_rows(url_instances)
  end

  def works_url_rows(work, type, url_rows: nil)
    return WorkUrlRows.normalize_collection(url_rows) if url_rows

    WorkUrlRows.new(work: work, type: type).rows
  end

  def notice_version_url_rows(work, type, notice)
    rows_obj = WorkUrlRows.new(work: work, type: type, notice: notice, user: current_user)

    if can_see_full_notice_version?(notice) || can_see_enterprise_notice_version?(notice)
      enterprise_access = can_see_enterprise_notice_version?(notice) ?
        EnterpriseNoticeAccess.new(current_user, notice) : nil
      rows_obj.visible_rows(
        enterprise_access: enterprise_access,
        bypass_restrictions: notice_safelisted?(notice)
      )
    else
      rows_obj.limited_rows
    end
  end

  def search_result_highlight_text(highlight_elem, notice = nil)
    if can?(:view_full_version, Notice)
      return highlight_elem unless content_filter_highlight_redaction_needed?(highlight_elem, notice)

      return with_redacted_urls(
        highlight_elem,
        notice: notice,
        redact_all_url_paths: false
      )
    end

    with_redacted_urls(
      highlight_elem,
      notice: notice,
      unredacted_domains: client_search_highlight_unredacted_domains
    )
  end

  def with_redacted_urls(text, notice: nil, unredacted_domains: [], redact_all_url_paths: true)
    sanitized_text = ActionView::Base.full_sanitizer.sanitize(text)
    redacted_text = redact_highlight_urls(
      sanitized_text,
      notice: notice,
      redact_all_url_paths: redact_all_url_paths,
      unredacted_domains: unredacted_domains
    )
    term_exact_search = (params['term'] && params['term'][0] == '"' && params['term'][-1] == '"')

    if params[:term].instance_of?(String)
      if term_exact_search
        words_to_highlight = [params[:term].gsub('"', '')]
      else
        words_to_highlight = params[:term].split(' ')
      end
    else
      words_to_highlight = []
    end

    highlight(redacted_text, words_to_highlight, highlighter: '<em>\1</em>')
  end

  def supporting_document_url(url)
    url + (params[:access_token] ? "&access_token=#{params[:access_token]}" : '')
  end

  # This prefills the submitter and recipient fields with info from a linked
  # entity, if the user has one.
  def placeholder_text(user, role, field)
    return {} unless [
      [:submitter, :recipient].include?(role.downcase.to_sym),
      user&.entity.present?
    ].all?

    { value: user.entity.send(field) }
  end

  def placeholder_country(user, role)
    return {} unless [
      [:submitter, :recipient].include?(role.downcase.to_sym),
      user&.entity&.country_code&.present?
    ].all?

    { selected: user&.entity&.country_code&.downcase.to_sym }
  end

  def placeholder_kind(user, role)
    return {} unless [
      [:submitter, :recipient].include?(role.downcase.to_sym),
      user&.entity.present?
    ].all?

    { selected: user.entity.kind }
  end

  private

  def notice_safelisted?(notice)
    (ENV['SAFELISTED_NOTICES_FULL'] || '').split(',').include?(notice.id.to_s)
  end

  def client_search_highlight_unredacted_domains
    return [] unless client_area?

    current_user&.active_enterprise_account&.verified_domain_names || []
  end

  def unredacted_url_path?(url, unredacted_domains)
    domains = Array(unredacted_domains)

    domains.any? && EnterpriseDomain.matches_url?(url, domains)
  end

  def redact_highlight_urls(text, notice:, redact_all_url_paths:, unredacted_domains: [])
    permissions = ContentFilter.user_permissions(current_user)
    notice_filters = highlight_notice_redaction_filters(notice, permissions)
    notice_forces_redaction = highlight_notice_forces_redaction?(notice, permissions)

    text.to_s.gsub(%r{\bhttps?://[^\s<>"']+}i) do |url|
      trailing_punctuation = url[/[.,;:!?)]*\z/]
      clean_url = url.delete_suffix(trailing_punctuation)
      url_filters = content_filter_highlight_url_filters(notice, clean_url)
      url_redaction_filters = url_filters.select { |f| f.restricts_user?(current_user, permissions: permissions) }
      all_filters = notice_filters + url_redaction_filters

      visible_url =
        if notice_forces_redaction || all_filters.any? ||
           (redact_all_url_paths && !unredacted_url_path?(clean_url, unredacted_domains))
          redact_url_path(clean_url)
        else
          clean_url
        end

      redact_content_filter_url_text(visible_url, all_filters) + trailing_punctuation
    end
  end

  def content_filter_highlight_redaction_needed?(highlight_elem, notice)
    permissions = ContentFilter.user_permissions(current_user)
    return true if highlight_notice_forces_redaction?(notice, permissions)
    return true if highlight_notice_redaction_filters(notice, permissions).any?

    sanitized_text = ActionView::Base.full_sanitizer.sanitize(highlight_elem)
    sanitized_text.to_s.scan(%r{\bhttps?://[^\s<>"']+}i).any? do |url|
      clean_url = url.delete_suffix(url[/[.,;:!?)]*\z/])
      url_filters = content_filter_highlight_url_filters(notice, clean_url)
      url_filters.any? { |f| f.restricts_user?(current_user, permissions: permissions) }
    end
  end

  def content_filter_highlight_url_filters(notice, url)
    return [] unless notice

    url_instance = Url.new(url: url, url_original: url)

    highlight_url_level_filters(notice).select do |content_filter|
      content_filter.matches_url?(url_instance)
    end
  end

  def highlight_url_level_filters(notice)
    @highlight_url_level_filters ||= {}
    @highlight_url_level_filters[notice.id || notice.object_id] ||=
      ContentFilter.url_filters_matching_notice(notice)
  end

  def highlight_notice_redaction_filters(notice, permissions)
    return [] unless notice

    @highlight_notice_redaction_filters ||= {}
    @highlight_notice_redaction_filters[notice.id || notice.object_id] ||=
      ContentFilter.notice_filters_matching_notice(notice).select do |f|
        f.restricts_user?(current_user, permissions: permissions)
      end
  end

  def highlight_notice_forces_redaction?(notice, permissions)
    return false unless notice

    (notice.restricted_to_lumen_team? && !permissions[:lumen_team]) ||
      (notice.restricted_to_researchers? && !permissions[:researcher])
  end

  def redact_content_filter_url_text(url, filters)
    filters.reduce(url) do |redacted_url, content_filter|
      next redacted_url if content_filter.url_text.blank?

      redacted_url.gsub(/#{Regexp.escape(content_filter.url_text)}/i, Lumen::REDACTION_MASK)
    end
  end

  def redact_url_path(url)
    uri = Addressable::URI.parse(url)
    return url unless uri&.host

    port = uri.port ? ":#{uri.port}" : ''

    "#{uri.scheme}://#{uri.host}#{port}/#{Lumen::REDACTION_MASK}"
  rescue Addressable::URI::InvalidURIError
    url
  end

  def confidential_order?(notice)
    notice.is_a?(CourtOrder) &&
      notice.subject&.include?('Google has not provided a copy to Lumen')
  end

  def display_date_field(record, field)
    return unless record && (date = record.send(field))
    time_tag date, date.to_fs(:simple)
  end

  def infringing_url_label(notice)
    case notice
    when ::DMCA, ::Trademark
      'Allegedly Infringing URL'
    when ::PrivateInformation
      'URL with private information'
    when ::CourtOrder
      'Targeted URL'
    when ::DataProtection, ::LawEnforcementRequest
      Translation.t('notice_show_works_law_enf_gov_infringing_url_label')
    when ::Defamation
      'Allegedly Defamatory URL'
    when ::Counterfeit
      'Allegedly Infringing Counterfeit URL'
    when ::LocalLaw
      Translation.t('notice_show_works_problematic_urls')
    when ::Other
      'Problematic URL'
    end
  end

  def copyrighted_url_label(notice)
    case notice
    when ::DMCA, ::Other
      'Original Work URL'
    when ::LawEnforcementRequest
      Translation.t('notice_show_works_law_enf_gov_copyrighted_url_label')
    end
  end

  def permanent_token_url(notice)
    TokenUrl.find_by(
      notice: notice,
      user: current_user,
      valid_forever: true
    )
  end

  def notice_cache_key(notice, can_see_full)
    enterprise_key = can_see_enterprise_notice_version?(notice) ? current_user.enterprise_cache_key : 'no-enterprise'
    key_part = "#{notice.cache_key}_#{params[:access_token]}_#{enterprise_key}"

    if can_see_full
      "untruncated_#{key_part}"
    elsif can_see_enterprise_notice_version?(notice)
      "enterprise_#{key_part}"
    elsif access_just_for_researchers?(notice)
      "truncated_just_researchers_#{key_part}"
    else
      "truncated_#{key_part}"
    end
  end

  def jsonb_array_input(notice, key)
    return '' if notice[key].nil?

    notice[key]
  end
end
