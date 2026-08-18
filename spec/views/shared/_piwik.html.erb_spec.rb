require 'rails_helper'

describe 'shared/_piwik.html.erb' do
  it 'tracks pageviews after configuring visitor identity and dimensions' do
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

    expect(rendered).to include('trackPageView')
    expect(rendered).to include('enableLinkTracking')
    expect(rendered).to include('setCustomDimension')
    expect(rendered).to include("setVisitorId', '0123456789abcdef'")
    track_pageview_position = rendered.index("_paq.push(['trackPageView'])")

    expect(rendered.index("_paq.push(['setVisitorId'")).to be < track_pageview_position
    expect(rendered.index("_paq.push(['setCustomDimension'")).to be < track_pageview_position
    expect(rendered.index("_paq.push(['setUserId'")).to be < track_pageview_position
  end
end
