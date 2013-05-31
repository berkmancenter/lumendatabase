module NoticesHelper
  def notice_source(notice)
    sent_via = case notice.source
               when 'web' then 'Online Form'
               when 'api' then 'API Submission'
               else 'Unknown'
               end

    content_tag(:p, class: 'source') do
      concat("Sent via: #{sent_via}")
    end
  end
end
