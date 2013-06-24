class RiskAssessment
  def initialize(notice)
    @notice = notice
  end

  def high_risk?
    risk_triggers.any? { |trigger| trigger.risky?(notice) }
  end

  private

  attr_reader :notice

  def risk_triggers
    RiskTrigger.all
  end
end
