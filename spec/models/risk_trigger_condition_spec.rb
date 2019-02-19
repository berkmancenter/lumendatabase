require 'spec_helper'

describe RiskTriggerCondition, type: :model do
  it { is_expected.to validate_presence_of :field }
  it { is_expected.to validate_presence_of :value }
  it { is_expected.to validate_inclusion_of(:field).in_array(RiskTriggerCondition::ALLOWED_FIELDS) }
  it { is_expected.to validate_inclusion_of(:matching_type).in_array(RiskTriggerCondition::ALLOWED_MATCHING_TYPES) }
  it { is_expected.to belong_to(:risk_trigger) }

  it 'sees a risky notice as risky' do
    notice = double('Notice')
    allow(notice).to receive_message_chain(:submitter, country_code: 'Spain')

    expect(example_trigger_condition).to be_risky(notice)
  end

  it 'uses negated to reverse the comparison' do
    notice = double('Notice')
    allow(notice).to receive_message_chain(:submitter, country_code: 'Spain')
    trigger = example_trigger_condition
    trigger.negated = false

    expect(trigger).not_to be_risky(notice)
  end

  it 'sees a safe notice as safe' do
    notice1 = double('Notice', country_code: 'United States')
    allow(notice1).to receive_message_chain(:submitter, country_code: 'United States')
    notice2 = double('Notice', country_code: 'Spain')
    allow(notice2).to receive_message_chain(:submitter, country_code: 'Spain')

    expect(example_trigger_condition).not_to be_risky(notice1)
    expect(example_trigger_condition).to be_risky(notice2)
  end

  it 'gracefully handles non-existent notice attributes' do
    invalid_trigger = RiskTriggerCondition.new(
      field: 'i_dont_exist'
    )

    expect(invalid_trigger).not_to be_risky(Notice.new)
  end

  def example_trigger_condition
    RiskTriggerCondition.new(
      field: 'submitter.country_code',
      value: 'United States',
      negated: true
    )
  end
end
