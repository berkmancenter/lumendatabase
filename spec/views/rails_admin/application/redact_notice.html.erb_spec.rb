require 'spec_helper'

describe 'rails_admin/application/redact_notice.html.erb' do
  before do
    class << view
      include RailsAdmin::Engine.routes.url_helpers
    end

    assign(:abstract_model, RailsAdmin::AbstractModel.new(Notice))
    assign(:redactable_fields, [])
    assign(:next_notice_path, nil)

    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it 'displays elapsed time in queue' do
    notice = build_stubbed(:notice)
    notice.stub(:created_at).and_return(2.hours.ago)
    assign(:object, notice)

    render

    expect(page).to have_content("Time in queue: about 2 hours")
  end

  it 'shows redactable_fields alongside originals' do
    notice = build_stubbed(
      :notice,
      legal_other: 'Redacted',
      legal_other_original: 'Original'
    )
    assign(:object, notice)
    assign(:redactable_fields, %i( legal_other ))

    render

    expect(page).to have_css(
      "textarea#notice_legal_other:contains('Redacted')"
    )
    expect(page).to have_css(
      "textarea#notice_legal_other_original:contains('Original')"
    )
  end

  it 'does not show publish checkbox if user cannot publish' do
    assign(:object, build_stubbed(:notice))

    render

    expect(page).not_to have_css('input#notice_review_required')
  end

  it 'shows publish checkbox if user can publish' do
    @ability.can :publish, Notice
    assign(:object, build_stubbed(:notice))

    render

    expect(page).to have_css('input#notice_review_required')
  end

  context "buttons and links" do
    before do
      assign(:object, build_stubbed(:notice))
      assign(:redactable_fields, [])
    end

    it "does not show 'Save and next' or 'Next' if there is no next model" do
      render

      expect(page).not_to have_css("input[value='Save and next']")
      expect(page).not_to have_css("a:contains('Next')")
    end

    it "shows 'Save and next' and 'Next' if there is a next model" do
      assign(:next_notice_path, 'http://example.com')

      render

      expect(page).to have_css("input[value='Save and next']")
      expect(page).to have_css("a:contains('Next')")
    end
  end
end
