module NoticesHelper

  def form_partial_for(instance)
    "#{instance.type.tableize.singularize}_form"
  end

  def show_partial_for(instance)
    "#{instance.type.tableize.singularize}_show"
  end

  def works_partial_for(instance)
    "#{instance.type.tableize.singularize}_works"
  end

  def display_date_field(record, field)
    if date = record.send(field)
      time_tag date, date.to_s(:simple)
    end
  end

  def date_sent(notice)
    display_date_field(notice, :date_sent)
  end

  def date_received(notice)
    display_date_field(notice, :date_received)
  end

  def subject(notice)
    if notice.subject.present?
      notice.subject
    else
      'Unknown'
    end
  end

  def sent_via(notice)
    if notice.source.present?
      notice.source
    else
      'Unknown'
    end
  end

  def iso_countries
    CountrySelect::ISO_COUNTRIES_FOR_SELECT
  end

  def first_time_visitor_content
    Markdown.render( t('first_time_visitor') )
  end

  def label_for_url_input(url_type, notice)
    case url_type
    when :infringing_urls
      case notice
      when ::DMCA, ::Trademark
        "Allegedly Infringing URL"
      when ::PrivateInformation
        "URL with private information"
      when ::CourtOrder
        "Targeted URL"
      when ::DataProtection, ::LawEnforcementRequest
        "URL mentioned in request"
      when ::Defamation
        "Allegedly Defamatory URL"
      when ::Other
        "Problematic URL"
      end
    when :copyrighted_urls
      case notice
      when ::DMCA, ::Other
        "Original Work URL"
      when ::LawEnforcementRequest
        "URL of original work"
      end
    else
      fail "Unknown url_type: #{url_type}"
    end
  end
end
