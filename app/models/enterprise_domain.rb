class EnterpriseDomain < ApplicationRecord
  belongs_to :enterprise_account

  before_validation :normalize_domain

  validates :domain,
            presence: true,
            uniqueness: { scope: :enterprise_account_id },
            format: {
              with: /\A[a-z0-9][a-z0-9.-]*\.[a-z0-9-]{2,}\z/,
              message: 'must be a domain name'
            }

  scope :verified, -> { where(verified: true) }

  def self.normalize(value)
    raw_value = value.to_s.strip.downcase
    raw_value = raw_value.sub(/\A\*\./, '').sub(/\A\./, '')
    return raw_value if raw_value.blank?

    value_for_parsing = if raw_value.match?(%r{\A[a-z][a-z0-9+\-.]*://}i)
                          raw_value
                        else
                          "http://#{raw_value}"
                        end

    Addressable::URI.parse(value_for_parsing).host.to_s
  rescue Addressable::URI::InvalidURIError
    raw_value.split('/').first.to_s
  end

  def self.host_from_url(value)
    raw_value = value.to_s.strip.downcase
    return if raw_value.blank?

    value_for_parsing = if raw_value.match?(%r{\A[a-z][a-z0-9+\-.]*://}i)
                          raw_value
                        else
                          "http://#{raw_value}"
                        end

    host = Addressable::URI.parse(value_for_parsing).host
    host.presence || Work.fqdn_from_url(raw_value).to_s.downcase
  rescue Addressable::URI::InvalidURIError
    Work.fqdn_from_url(raw_value).to_s.downcase
  end

  def self.matches_url?(url, domains)
    host = host_from_url(url)
    return false if host.blank?

    domains.any? do |domain|
      normalized_domain = normalize(domain)

      host == normalized_domain || host.end_with?(".#{normalized_domain}")
    end
  end

  private

  def normalize_domain
    self.domain = self.class.normalize(domain)
  end
end
