require 'spec_helper'

describe RiskTrigger, type: :model do
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :matching_type }
  it { is_expected.to validate_inclusion_of(:matching_type).in_array(RiskTrigger::ALLOWED_MATCHING_TYPES) }
  it { is_expected.to have_many(:risk_trigger_conditions) }

  it 'sees a not risky notice when a trigger has no conditions' do
    notice = double('Notice')
    trigger = RiskTrigger.new(name: 'No risk no fun')

    expect(trigger).not_to be_risky(notice)
  end

  it 'sees a risky notice when a trigger has a single risky condition for both all and any matching types' do
    notice = double('Notice', title: 'So risky')
    trigger_all = RiskTrigger.new(name: 'No risk no fun', matching_type: 'all')
    trigger_any = RiskTrigger.new(name: 'Some risk is fun', matching_type: 'any')
    condition = create_condition('title', 'risky', false, 'broad')

    trigger_all.risk_trigger_conditions = [condition]
    expect(trigger_all).to be_risky(notice)

    trigger_any.risk_trigger_conditions = [condition]
    expect(trigger_any).to be_risky(notice)
  end

  it 'sees a risky notice when a trigger has two risky conditions for both all and any matching types' do
    notice = double('Notice', title: 'So risky', body: 'So risky too')
    trigger_all = RiskTrigger.new(name: 'No risk no fun', matching_type: 'all')
    trigger_any = RiskTrigger.new(name: 'Some risk is fun', matching_type: 'any')
    condition1 = create_condition('title', 'risky', false, 'broad')
    condition2 = create_condition('body', 'risky', false, 'broad')

    trigger_all.risk_trigger_conditions = [condition1, condition2]
    expect(trigger_all).to be_risky(notice)

    trigger_any.risk_trigger_conditions = [condition1, condition2]
    expect(trigger_any).to be_risky(notice)
  end

  it 'sees a not risky notice when a trigger has two risky conditions and the all matching type and only matched' do
    notice = double('Notice', title: 'So risky', body: 'Well, I\'m not')
    trigger = RiskTrigger.new(name: 'No risk no fun', matching_type: 'all')
    condition1 = create_condition('title', 'risky', false, 'broad')
    condition2 = create_condition('body', 'risky', false, 'broad')

    trigger.risk_trigger_conditions = [condition1, condition2]
    expect(trigger).not_to be_risky(notice)
  end

  it 'sees a risky notice when a trigger has two risky conditions and the any matching type and only matched' do
    notice = double('Notice', title: 'So risky', body: 'Well, I\'m not')
    trigger = RiskTrigger.new(name: 'No risk no fun', matching_type: 'any')
    condition1 = create_condition('title', 'risky', false, 'broad')
    condition2 = create_condition('body', 'risky', false, 'broad')

    trigger.risk_trigger_conditions = [condition1, condition2]
    expect(trigger).to be_risky(notice)
  end

  private

  def create_condition(field, value, negated, matching_type)
    RiskTriggerCondition.new(
      field: field,
      value: value,
      negated: negated,
      matching_type: matching_type
    )
  end
end
