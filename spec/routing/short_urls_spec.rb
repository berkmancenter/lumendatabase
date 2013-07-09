require 'spec_helper'

describe "Notices" do
  it "routes /n/notice_id to NoticesController#show" do
    expect(get: '/n/1234').to route_to(
      controller:  "notices",
      action: "show",
      id: "1234"
    )
  end

end
