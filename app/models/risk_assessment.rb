class RiskAssessment
  def initialize(notice)
    @notice = notice
  end

  def high_risk?
    risky = false

    risk_triggers.each do |trigger|
      trigger_risky = trigger.risky?(notice)

      if trigger_risky && trigger.force_not_risky_assessment?
        risky = false
        break
      end

      risky = true if trigger_risky
    end

    risky
  end

  private

  attr_reader :notice

  def risk_triggers
    RiskTrigger.all
  end
end
