require 'spec_helper'

describe 'Notices::Searches' do
  it "routes notices/search to Notices::SearchController#index" do
    expect(get: 'notices/search').to route_to(
      controller: 'notices/search',
      action: 'index'
    )
  end

  it "routes enterprise/notices/search to Enterprise::Notices::SearchController#index" do
    expect(get: 'enterprise/notices/search').to route_to(
      controller: 'enterprise/notices/search',
      action: 'index'
    )
  end

  it "routes enterprise/settings to Enterprise::SettingsController#show" do
    expect(get: 'enterprise/settings').to route_to(
      controller: 'enterprise/settings',
      action: 'show'
    )
  end
end
