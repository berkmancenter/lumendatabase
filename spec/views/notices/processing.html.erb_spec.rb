require 'rails_helper'

RSpec.describe 'notices/processing.html.erb', type: :view do
  it 'explains that the notice will be visible after processing' do
    submission_request = create(:notice_submission_request)
    assign(:notice_submission_request, submission_request)

    render

    expect(rendered).to include('Notice is being processed')
    expect(rendered).to include('It will be visible')
    expect(rendered).to include("Notice ID: #{submission_request.reserved_notice_id}")
  end

  it 'shows the same processing message for a delayed submission' do
    assign(
      :notice_submission_request,
      create(:notice_submission_request, status: 'failed', attempts: 1)
    )

    render

    expect(rendered).to include('This notice has been received and is being processed')
    expect(rendered).not_to include('taking longer than expected')
  end
end
