require 'rails_helper'

feature "Publishing high risk notices" do
  let(:harmless_text) { "Some harmless text" }

  scenario "A non-US notice with Body text" do
    create_non_us_risk_trigger

    submit_notice_from('Spain') do
      fill_in "Body", with: harmless_text
    end

    open_recent_notice
    within('.notice-body') do
      expect(page).to have_content Notice::UNDER_REVIEW_VALUE
    end
  end

  scenario "A US notice with Body text" do
    create_non_us_risk_trigger

    submit_notice_from('United States') do
      fill_in "Body", with: harmless_text
    end

    open_recent_notice
    within('.notice-body') do
      expect(page).to have_content harmless_text
    end
  end

  private

  def create_non_us_risk_trigger
    RiskTrigger.create!(
      field: 'body',
      condition_field: 'country_code',
      condition_value: 'us',
      negated: true
    )
  end

  def submit_notice_from(country)
    submit_recent_notice do
      within('section.recipient') do
        select country, from: "Country"
      end

      yield if block_given?
    end
  end
end
