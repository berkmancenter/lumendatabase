require 'ipaddr'
require 'net/http'
require 'net/https'
require 'resolv'
require 'uri'

class Lumen::Enterprise::DomainVerification
  MAX_RESPONSE_BYTES = 1024
  PRIVATE_IP_RANGES = [
    IPAddr.new('0.0.0.0/8'),
    IPAddr.new('10.0.0.0/8'),
    IPAddr.new('127.0.0.0/8'),
    IPAddr.new('169.254.0.0/16'),
    IPAddr.new('172.16.0.0/12'),
    IPAddr.new('192.168.0.0/16'),
    IPAddr.new('::1/128'),
    IPAddr.new('fc00::/7'),
    IPAddr.new('fe80::/10')
  ].freeze

  attr_reader :enterprise_domain

  def initialize(enterprise_domain)
    @enterprise_domain = enterprise_domain
  end

  def verified?
    return false unless publicly_resolvable?

    verification_uris.any? do |uri|
      response_body(uri) == enterprise_domain.verification_file_content
    end
  end

  private

  def verification_uris
    verification_path = "/#{enterprise_domain.verification_filename}"

    [
      URI::HTTPS.build(host: enterprise_domain.domain, path: verification_path),
      URI::HTTP.build(host: enterprise_domain.domain, path: verification_path)
    ]
  end

  def response_body(uri)
    response = Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: uri.scheme == 'https',
      open_timeout: 5,
      read_timeout: 5
    ) do |http|
      http.get(uri.request_uri, 'User-Agent' => 'Lumen domain verifier')
    end

    return unless response.is_a?(Net::HTTPSuccess)

    response.body.to_s.byteslice(0, MAX_RESPONSE_BYTES).to_s.strip
  rescue SocketError, SystemCallError, Timeout::Error, Net::OpenTimeout,
         Net::ReadTimeout, OpenSSL::SSL::SSLError
    nil
  end

  def publicly_resolvable?
    resolved_ips.present? && resolved_ips.none? { |ip| private_ip?(ip) }
  rescue Resolv::ResolvError
    false
  end

  def resolved_ips
    @resolved_ips ||= Resolv.getaddresses(enterprise_domain.domain).map do |ip|
      IPAddr.new(ip)
    end
  end

  def private_ip?(ip)
    PRIVATE_IP_RANGES.any? { |range| range.include?(ip) }
  end
end
