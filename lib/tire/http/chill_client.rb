module Tire
  module HTTP
    module Client
      class ChillClient < RestClient
        def self.get(url, data = nil)
          perform ::RestClient::Request.new(
            method: :get,
            url: url,
            timeout: 10,
            open_timeout: 10,
            payload: data).execute
        rescue *ConnectionExceptions
          raise
        rescue ::RestClient::Exception => e
          Response.new e.http_body, e.http_code
        end
      end
    end
  end
end
