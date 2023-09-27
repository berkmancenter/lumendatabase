module ProxyCache
  CLEAR_HEADER = ENV['PROXY_CACHE_CLEAR_HEADER']
  REQUEST_SLEEP_SECONDS = 5

  def self.clear_notice(notice_ids)
    return if CLEAR_HEADER.nil?

    if notice_ids.is_a? Array
      call_many(notice_ids)
    else
      call(notice_url(notice_ids))
    end
  end

  def self.call(url, timeout = nil)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Host'] = uri.host
    request[CLEAR_HEADER] = 'yolo'

    Thread.new do
      sleep(timeout.to_i) if timeout
      http.request(request)
    end
  end

  def self.call_many(notice_ids)
    i = 1

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
