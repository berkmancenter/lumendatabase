module ProxyCache
  CLEAR_HEADER = ENV['PROXY_CACHE_CLEAR_HEADER']
  REQUEST_SLEEP_SECONDS = 5

  def self.clear_notice(notice_ids)
    return if CLEAR_HEADER.nil?

    notice_ids = [notice_ids] unless notice_ids.is_a? Array

    call_many(notice_ids)
  end

  def self.call(url, delay = 0)
    ClearCacheJob.set(wait: delay.seconds).perform_later(url)
  end

  def self.call_many(notice_ids)
    i = 0

    notice_ids.each do |notice_id|
      call(
        notice_url(notice_id),
        i * REQUEST_SLEEP_SECONDS
      )

      i += 1
    end
  end

  def self.notice_url(notice_id)
    Rails.application.routes.url_helpers.notice_url(
      host: Chill::Application.config.site_host,
      id: notice_id
    )
  end
end
