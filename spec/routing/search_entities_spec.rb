require 'spec_helper'

describe 'Entities::Searches' do
  it "routes entities/search to Entities::SearchController#index" do
    expect(get: 'entities/search').to route_to(
      controller: 'entities/search',
      action: 'index'
    )
  end
end
