module NoticesHelper
  # Determines whether 'click to request access' should be an option.
  # Yes, the messy function signature implies there is a lot going on with the
  # business logic.
  def access_requestable?(notice, show_original, show_infringing)
    [
      show_original || show_infringing,
      # Additional access cannot be requested for confidential court orders
      # as there is nothing further to display.
      !confidential_order?(notice)
    ].all?
  end

  def access_just_for_researchers?(notice)
    notice&.submitter&.full_notice_only_researchers
  end

  def access_just_for_specific_researchers?(notice)
    notice&.submitter&.full_notice_only_researchers_users&.any?
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

  def iso_countries
    CountrySelect::ISO_COUNTRIES_FOR_SELECT
  end

  def first_time_visitor_content
    MarkdownParser.render(t('first_time_visitor'))
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

  def with_redacted_urls(text)
    redacted_text = text.gsub(
      %r{(http[s]?://[w]*[\.]*[^/|$]*)(\S*)},
      '\1/[REDACTED]'
    )

    redacted_text
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

  def confidential_order?(notice)
    notice.is_a?(CourtOrder) &&
      notice.subject&.include?('Google has not provided a copy to Lumen')
  end

  def display_date_field(record, field)
    return unless record && (date = record.send(field))
    time_tag date, date.to_s(:simple)
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
      'URL mentioned in request'
    when ::Defamation
      'Allegedly Defamatory URL'
    when ::Counterfeit
      'Allegedly Infringing Counterfeit URL'
    when ::Other
      'Problematic URL'
    end
  end

  def copyrighted_url_label(notice)
    case notice
    when ::DMCA, ::Other
      'Original Work URL'
    when ::LawEnforcementRequest
      'URL of original work'
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
    key_part = "#{notice.cache_key}_#{params[:access_token]}"

    if can_see_full
      "untruncated_#{key_part}"
    elsif access_just_for_researchers?(notice)
      "truncated_just_researchers_#{key_part}"
    else
      "truncated_#{key_part}"
    end
  end
end
