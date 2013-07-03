module NoticesHelper
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
end
