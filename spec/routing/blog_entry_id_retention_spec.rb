require 'spec_helper'

describe "BlogEntry URL retention routes" do
  it "routes /original_news_id/1234 to OriginalNewsId#show" do
    expect(get: "/original_news_id/1234").to route_to(
      controller:  "original_news_ids",
      action: "show",
      id: "1234"
    )
  end

end
