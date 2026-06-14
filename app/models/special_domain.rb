require 'lumen/models'
require 'lumen/models/validates_automatically'

class SpecialDomain < ApplicationRecord
  include Lumen::Models::ValidatesAutomatically

  validates :domain_name, presence: true

  def why_special_enum
    [
      ['Full urls only for researchers', :full_urls_only_for_researchers]
    ]
  end

  def self.full_urls_only_for_researchers_patterns
    where("why_special ? 'full_urls_only_for_researchers'").pluck(:domain_name)
  end

  def self.matches_pattern?(url, pattern)
    regex = Regexp.escape(pattern.to_s)
                  .gsub('%', '.*')
                  .gsub('_', '.')

    url.to_s.match?(/\A#{regex}\z/i)
  end
end
