require 'spec_helper'

describe RiskTrigger do
  it "sees a risky notice as risky" do
    notice = double("Notice", country_code: 'Spain', body: "nonempty")

    expect(example_trigger).to be_risky(notice)
  end

  it "uses negated to reverse the comparison" do
    notice = double("Notice", country_code: 'Spain', body: "nonempty")
    trigger = example_trigger
    trigger.negated = false

    expect(trigger).not_to be_risky(notice)
  end

  it "sees a safe notice as safe" do
    notice_1 = double("Notice", country_code: 'United States', body: "nonempty")
    notice_2 = double("Notice", country_code: 'Spain', body: nil)

    expect(example_trigger).not_to be_risky(notice_1)
    expect(example_trigger).not_to be_risky(notice_2)
  end

  it "gracefully handles non-existent notice attributes" do
    invalid_trigger =RiskTrigger.new(
      field: :i_dont_exist,
      condition_field: :either_do_i,
    )

    expect(invalid_trigger).not_to be_risky(Notice.new)
  end

  def example_trigger
    RiskTrigger.new(
      field: :body,
      condition_field: :country_code,
      condition_value: 'United States',
      negated: true
    )
  end
end
