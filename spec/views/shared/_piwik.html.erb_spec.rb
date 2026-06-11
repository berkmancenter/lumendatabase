require 'rails_helper'

describe 'shared/_piwik.html.erb' do
  it 'does not track pageviews in the browser' do
    stub_const(
      'Piwik',
      {
        'disabled' => false,
        'url' => 'stats.example.test',
        'id_site' => 1
      }
    )
    allow(view).to receive(:matomo_dimension_parameters).and_return(
      'dimension1' => 'credentialed'
    )
    allow(view).to receive(:matomo_tracking_dimensions).and_return(
      authenticated_user_email: 'user@example.test'
    )
    allow(view).to receive(:matomo_visitor_id).and_return('0123456789abcdef')

    render partial: 'shared/piwik'

    expect(rendered).not_to include('trackPageView')
    expect(rendered).to include('enableLinkTracking')
    expect(rendered).to include('setCustomDimension')
    expect(rendered).to include("setVisitorId', '0123456789abcdef'")
  end
end
