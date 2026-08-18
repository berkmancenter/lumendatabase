require 'rails_helper'

describe 'config/initializers/piwik.rb' do
  around do |example|
    original_piwik_defined = Object.const_defined?(:Piwik)
    original_piwik = Object.const_get(:Piwik) if original_piwik_defined
    original_token_auth = ENV['MATOMO_TOKEN_AUTH']
    original_server_tracking_enabled = ENV['MATOMO_SERVER_TRACKING_ENABLED']

    example.run
  ensure
    ENV['MATOMO_TOKEN_AUTH'] = original_token_auth
    ENV['MATOMO_SERVER_TRACKING_ENABLED'] = original_server_tracking_enabled
    Object.send(:remove_const, :Piwik) if Object.const_defined?(:Piwik)
    Object.const_set(:Piwik, original_piwik) if original_piwik_defined
  end

  it 'injects the Matomo API token from the environment' do
    ENV['MATOMO_TOKEN_AUTH'] = 'secret-token'

    reload_piwik_initializer

    expect(Piwik['token_auth']).to eq('secret-token')
  end

  it 'omits token auth when the environment value is blank' do
    ENV['MATOMO_TOKEN_AUTH'] = ''

    reload_piwik_initializer

    expect(Piwik).not_to have_key('token_auth')
  end

  it 'enables server-side tracking through the environment' do
    ENV['MATOMO_SERVER_TRACKING_ENABLED'] = 'true'

    reload_piwik_initializer

    expect(Piwik['server_tracking_enabled']).to be(true)
  end

  it 'disables server-side tracking through the environment' do
    ENV['MATOMO_SERVER_TRACKING_ENABLED'] = 'false'

    reload_piwik_initializer

    expect(Piwik['server_tracking_enabled']).to be(false)
  end

  def reload_piwik_initializer
    Object.send(:remove_const, :Piwik) if Object.const_defined?(:Piwik)
    load Rails.root.join('config/initializers/piwik.rb').to_s
  end
end
