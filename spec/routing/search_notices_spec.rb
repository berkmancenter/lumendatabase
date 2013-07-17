require 'spec_helper'

describe 'Notices::Searches' do
  it "routes notices/search to Notices::SearchController#index" do
    expect(get: 'notices/search').to route_to(
      controller: 'notices/search',
      action: 'index'
    )
  end
end
