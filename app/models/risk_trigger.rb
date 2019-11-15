class RiskTrigger < ApplicationRecord
  ALLOWED_MATCHING_TYPES = %w[any all].freeze

  has_many :risk_trigger_conditions, dependent: :destroy

  validates_presence_of :name, :matching_type
  validates_inclusion_of :matching_type, in: ALLOWED_MATCHING_TYPES

  def risky?(notice)
    return false unless risk_trigger_conditions.any?

    if matching_type == 'any'
      risk_trigger_conditions.any? { |condition| condition.risky?(notice) }
    else
      risk_trigger_conditions.all? { |condition| condition.risky?(notice) }
    end
  end
end
