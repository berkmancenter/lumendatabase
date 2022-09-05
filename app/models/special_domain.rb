require 'validates_automatically'

class SpecialDomain < ApplicationRecord
  include ValidatesAutomatically

  validates :domain_name, presence: true

  def why_special_enum
    [
      ['Full urls only for researchers', :full_urls_only_for_researchers]
    ]
  end
end
