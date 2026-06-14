require 'spec_helper'

describe Lumen::RiskAssessment, type: :model do
  it "returns true if any trigger triggers" do
    triggers = [
      trigger_1 = double("Trigger 1"),
      trigger_2 = double("Trigger 2")
    ]
    allow(RiskTrigger).to receive(:all).and_return(triggers)
    notice = double("Notice")
    expect(trigger_1).to receive(:risky?).with(notice).and_return(false)
    expect(trigger_2).to receive(:risky?).with(notice).and_return(true)

    assessment = Lumen::RiskAssessment.new(notice)

    expect(assessment).to be_high_risk
  end

  it "returns false if no trigger triggers" do
    allow(RiskTrigger).to receive(:all).and_return([
      double("Trigger 1", risky?: false),
      double("Trigger 2", risky?: false),
      double("Trigger 3", risky?: false)
    ])
    notice = double("Notice")

    assessment = Lumen::RiskAssessment.new(notice)

    expect(assessment).not_to be_high_risk
  end
end
