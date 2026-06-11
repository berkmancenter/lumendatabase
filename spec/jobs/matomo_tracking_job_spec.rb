require 'rails_helper'

describe MatomoTrackingJob do
  it 'posts usage payloads to Matomo' do
    stub_const(
      'Piwik',
      {
        'disabled' => false,
        'id_site' => 4,
        'tracking_url' => 'http://matomo',
        'custom_dimensions' => {}
      }
    )

    request = stub_request(:post, 'http://matomo/matomo.php')
      .with(
        body: hash_including(
          'idsite' => '4',
          'rec' => '1',
          'send_image' => '0',
          'apiv' => '1',
          'url' => 'http://example.test/notices/search.json',
          'action_name' => 'notices/search#index',
          'dimension1' => 'credentialed'
        )
      )
      .to_return(status: 204)

    described_class.perform_now(
      url: 'http://example.test/notices/search.json',
      action_name: 'notices/search#index',
      dimension1: 'credentialed'
    )

    expect(request).to have_been_requested
  end

  it 'does not post when Matomo is disabled' do
    stub_const('Piwik', { 'disabled' => true })
    request = stub_request(:post, 'http://matomo/matomo.php')

    described_class.perform_now(url: 'http://example.test/notices/search.json')

    expect(request).not_to have_been_requested
  end

  it 'logs rejected Matomo responses' do
    stub_const(
      'Piwik',
      {
        'disabled' => false,
        'id_site' => 4,
        'tracking_url' => 'http://matomo'
      }
    )
    stub_request(:post, 'http://matomo/matomo.php')
      .to_return(status: 400, body: 'bad dimension')

    expect(Rails.logger).to receive(:warn)
      .with('Matomo tracking returned 400: bad dimension')

    described_class.perform_now(url: 'http://example.test/notices/search.json')
  end
end
