class ClearCacheJob < ApplicationJob
  queue_as :default

  def perform(url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Host'] = uri.host
    request[ProxyCache::CLEAR_HEADER] = 'yolo'

    http.request(request)
  end
end
