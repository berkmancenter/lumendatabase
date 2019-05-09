require 'rails_helper'

feature 'Publishing high risk notices' do
  include NoticeActions

  let(:harmless_text) { 'Some harmless text' }

  scenario 'A non-US notice with a non-us trigger condition is risky' do
    create_non_us_risk_trigger

    submit_notice_from('Spain') do
      fill_in 'Body', with: harmless_text
    end

    open_recent_notice
    within('.notice-body') do
      expect(page).to have_words Notice::UNDER_REVIEW_VALUE
    end
  end

  scenario 'A US notice with a non-us trigger condition is not risky' do
    create_non_us_risk_trigger

    submit_notice_from('United States') do
      fill_in 'Body', with: harmless_text
    end

    open_recent_notice
    within('.notice-body') do
      expect(page).to have_words harmless_text
    end
  end

  scenario 'A notice and a trigger that should match all with two conditions and matching all of them is risky' do
    condition1 = create_condition('notice.title', 'risky', false, 'broad')
    condition2 = create_condition('notice.body', 'risky', false, 'broad')
    create_trigger('Risky stuff', 'all', [condition1, condition2])

    submit_notice_from('United States') do
      fill_in 'Title', with: 'I\'m so risky title, woooo!'
      fill_in 'Body', with: 'I\'m so risky body, watch out!'
    end

    open_recent_notice
    within('.notice-body') do
      expect(page).to have_words Notice::UNDER_REVIEW_VALUE
    end
  end

  scenario 'A notice and a trigger that should match all with two conditions and matching just one of them is not risky' do
    condition1 = create_condition('notice.title', 'risky', false, 'broad')
    condition2 = create_condition('notice.body', 'risky', false, 'broad')
    create_trigger('Risky stuff', 'all', [condition1, condition2])

    submit_notice_from('United States') do
      fill_in 'Title', with: 'I\'m so risky title, woooo!'
      fill_in 'Body', with: harmless_text
    end

    open_recent_notice
    within('.notice-body') do
      expect(page).to have_words harmless_text
    end
  end

  scenario 'A notice and a trigger that should match any with two conditions and matching just one of them is risky' do
    condition1 = create_condition('notice.title', 'risky', false, 'broad')
    condition2 = create_condition('notice.body', 'risky', false, 'broad')
    create_trigger('Risky stuff', 'any', [condition1, condition2])

    submit_notice_from('United States') do
      fill_in 'Title', with: 'I\'m so risky title, woooo!'
      fill_in 'Body', with: harmless_text
    end

    open_recent_notice
    within('.notice-body') do
      expect(page).to have_words Notice::UNDER_REVIEW_VALUE
    end
  end

  scenario 'A notice and a trigger with exact conditions match and is risky' do
    condition1 = create_condition('notice.title', 'risky1', false, 'exact')
    condition2 = create_condition('notice.body', 'risky2', false, 'exact')
    create_trigger('Risky stuff', 'all', [condition1, condition2])

    submit_notice_from('United States') do
      fill_in 'Title', with: 'risky1'
      fill_in 'Body', with: 'risky2'
    end

    open_recent_notice
    within('.notice-body') do
      expect(page).to have_words Notice::UNDER_REVIEW_VALUE
    end
  end

  scenario 'A notice checked against a trigger with no conditions is not risky' do
    create_trigger('Risky stuff', 'all', [])

    submit_notice_from('United States') do
      fill_in 'Title', with: 'risky1'
      fill_in 'Body', with: 'risky2'
    end

    open_recent_notice
    within('.notice-body') do
      expect(page).not_to have_words Notice::UNDER_REVIEW_VALUE
    end
  end

  private

  def create_non_us_risk_trigger
    risk_trigger_condition = create_condition('recipient.country_code', 'us', true, 'exact')
    create_trigger('Non US risk trigger', 'all', [risk_trigger_condition])
  end

  def create_condition(field, value, negated, matching_type)
    RiskTriggerCondition.create!(
      field: field,
      value: value,
      negated: negated,
      matching_type: matching_type
    )
  end

  def create_trigger(name, matching_type, conditions)
    RiskTrigger.create!(
      name: name,
      matching_type: matching_type,
      risk_trigger_conditions: conditions
    )
  end

  def submit_notice_from(country)
    submit_recent_notice do
      within('section.recipient') do
        select country, from: 'Country'
      end

      yield if block_given?
    end
  end
end
