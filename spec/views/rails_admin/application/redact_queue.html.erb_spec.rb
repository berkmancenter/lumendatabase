require 'spec_helper'

describe 'rails_admin/application/redact_queue.html.erb' do
  before do
    # in the view spec context, the default url for the form_tag is not
    # a valid route for some reason. there's no testable behavior there
    # anyway, so we'll just stub it out.
    view.stub(:form_tag).and_yield

    assign(:refill, double(each_input: nil))
    assign(:objects, [])
  end

  it "Includes the ID, Title, Body, Entities, and Date received" do
    notice = build_stubbed(
      :notice,
      :with_body,
      role_names: %w( sender, recipient, submitter ),
      date_received: Time.now
    )
    assign(:objects, [notice])

    render

    expect(page).to have_content(notice.id)
    expect(page).to have_content(notice.title)
    expect(page).to have_content(notice.body)
    expect(page).to have_content(notice.sender_name)
    expect(page).to have_content(notice.recipient_name)
    expect(page).to have_content(notice.submitter_name)
    expect(page).to have_content(notice.date_received.to_s(:simple))
  end

end
