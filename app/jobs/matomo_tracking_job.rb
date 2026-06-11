# frozen_string_literal: true

require 'net/http'
require 'securerandom'
require 'uri'

class MatomoTrackingJob < ApplicationJob
  queue_as :default

  def perform(payload)
    return if Piwik['disabled']

    http = Net::HTTP.new(endpoint_uri.host, endpoint_uri.port)
    http.use_ssl = endpoint_uri.scheme == 'https'
    http.open_timeout = 2
    http.read_timeout = 2

    request = Net::HTTP::Post.new(endpoint_uri.request_uri)
    request.set_form_data(base_payload.merge(payload))

    response = http.request(request)
    return if response.is_a?(Net::HTTPSuccess)

    Rails.logger.warn(
      "Matomo tracking returned #{response.code}: #{response.body.to_s.truncate(500)}"
    )
  rescue StandardError => e
    Rails.logger.warn("Matomo tracking failed: #{e.class}: #{e.message}")
  end

  private

  def base_payload
    {
      idsite: Piwik['id_site'],
      rec: 1,
      send_image: 0,
      rand: SecureRandom.hex(8),
      apiv: 1
    }
  end

  def endpoint_uri
    @endpoint_uri ||= URI.join(tracking_base_url, 'matomo.php')
  end

  def tracking_base_url
    raw_url = Piwik['tracking_url'].presence || Piwik['url']
    raw_url.end_with?('/') ? raw_url : "#{raw_url}/"
  end
end
