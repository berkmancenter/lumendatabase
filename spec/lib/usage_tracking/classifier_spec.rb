require 'rails_helper'

describe Lumen::UsageTracking::Classifier do
  it 'classifies anonymous web traffic' do
    classifier = described_class.new(
      request: request_for('/notices/1'),
      user: nil
    )

    expect(classifier.dimensions).to eq(
      credential_status: 'uncredentialed',
      auth_method: 'anonymous',
      surface: 'web'
    )
  end

  it 'classifies logged-in web traffic as session credentialed' do
    user = create(:user, email: 'researcher@example.test')
    classifier = described_class.new(
      request: request_for('/notices/1'),
      user: user
    )

    expect(classifier.dimensions).to eq(
      credential_status: 'credentialed',
      auth_method: 'session',
      surface: 'web',
      authenticated_user_email: 'researcher@example.test'
    )
  end

  it 'classifies token-authenticated JSON traffic as API credentialed' do
    user = create(:user, :researcher, email: 'api@example.test')
    classifier = described_class.new(
      request: request_for("/notices/search.json?authentication_token=#{user.authentication_token}"),
      user: user,
      authenticated_from_api_token: true
    )

    expect(classifier.dimensions).to eq(
      credential_status: 'credentialed',
      auth_method: 'api token',
      surface: 'api',
      authenticated_user_email: 'api@example.test'
    )
  end

  it 'classifies notice access token traffic as credentialed' do
    notice = create(:dmca)
    token_url = TokenUrl.create!(
      email: 'token-holder@example.test',
      notice: notice
    )

    classifier = described_class.new(
      request: request_for("/notices/#{notice.id}?access_token=#{token_url.token}"),
      user: nil,
      notice: notice
    )

    expect(classifier.dimensions).to eq(
      credential_status: 'credentialed',
      auth_method: 'notice token',
      surface: 'web'
    )
  end

  it 'maps usage dimensions to configured Matomo custom dimension parameters' do
    set_dimension_setting('matomo_dimension_credential_status_id', '5')
    set_dimension_setting('matomo_dimension_auth_method_id', '6')
    set_dimension_setting('matomo_dimension_surface_id', '7')
    set_dimension_setting('matomo_dimension_authenticated_user_email_id', '8')

    user = create(:user, email: 'user@example.test')
    classifier = described_class.new(
      request: request_for('/notices/1'),
      user: user
    )

    expect(classifier.matomo_dimension_parameters).to eq(
      'dimension5' => 'credentialed',
      'dimension6' => 'session',
      'dimension7' => 'web',
      'dimension8' => 'user@example.test'
    )
  end

  def request_for(path)
    ActionDispatch::Request.new(Rack::MockRequest.env_for(path))
  end

  def set_dimension_setting(key, value)
    setting = LumenSetting.find_or_initialize_by(key: key)
    setting.update!(
      name: key.humanize,
      value: value
    )
  end
end
