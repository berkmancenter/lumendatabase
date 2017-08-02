require 'rails_helper'

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
    allow(controller).to receive(:current_ability) { @ability }
  end

  it 'displays elapsed time in queue' do
    notice = build_stubbed(:dmca)
    allow(notice).to receive(:created_at).and_return(2.hours.ago)
    assign(:object, notice)

    render

    expect(rendered).to have_content("Time in queue: about 2 hours")
  end

  it 'displays notice id, and entity names' do
    notice = build_stubbed(
      :dmca, role_names: %w( submitter recipient sender )
    )
    assign(:object, notice)

    render

    expect(rendered).to have_content(notice.id)
    expect(rendered).to have_content(notice.submitter_name)
    expect(rendered).to have_content(notice.recipient_name)
    expect(rendered).to have_content(notice.sender_name)
  end

  it 'shows redactable_fields alongside originals' do
    notice = build_stubbed(
      :dmca,
      body: 'Redacted',
      body_original: 'Original'
    )
    assign(:object, notice)
    assign(:redactable_fields, %i( body ))

    render

    expect(rendered).to have_css(
      "textarea#notice_body:contains('Redacted')"
    )
    expect(rendered).to have_css(
      "textarea#notice_body_original:contains('Original')"
    )
  end

  it 'does not show publish checkbox if user cannot publish' do
    assign(:object, build_stubbed(:dmca))

    render

    expect(rendered).not_to have_css('input#notice_review_required')
  end

  it 'shows publish checkbox if user can publish' do
    @ability.can :publish, Notice
    assign(:object, build_stubbed(:dmca))

    render

    expect(rendered).to have_css('input#notice_review_required')
  end

  context "buttons and links" do
    before do
      assign(:object, build_stubbed(:dmca))
      assign(:redactable_fields, [])
    end

    it "does not show 'Save and next' or 'Next' if there is no next model" do
      render

      expect(rendered).not_to have_css("input[value='Save and next']")
      expect(rendered).not_to have_css("a:contains('Next')")
    end

    it "shows 'Save and next' and 'Next' if there is a next model" do
      assign(:next_notice_path, 'http://example.com')

      render

      expect(rendered).to have_css("input[value='Save and next']")
      expect(rendered).to have_css("a:contains('Next')")
    end
  end
end
