require 'spec_helper'

describe 'Notices::Searches' do
  it "routes notices/search to Notices::SearchController#index" do
    expect(get: 'notices/search').to route_to(
      controller: 'notices/search',
      action: 'index'
    )
  end

  it "routes client/notices/search to Client::Notices::SearchController#index" do
    expect(get: 'client/notices/search').to route_to(
      controller: 'client/notices/search',
      action: 'index'
    )
  end

  it "routes client to Client::DashboardController#index" do
    expect(get: 'client').to route_to(
      controller: 'client/dashboard',
      action: 'index'
    )
  end

  it "routes client/settings to Client::SettingsController#show" do
    expect(get: 'client/settings').to route_to(
      controller: 'client/settings',
      action: 'show'
    )
  end
end
