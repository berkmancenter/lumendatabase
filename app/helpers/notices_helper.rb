module NoticesHelper
  def date_received(notice)
    if date = notice.date_received
      time_tag date, date.to_s(:simple)
    end
  end
end
