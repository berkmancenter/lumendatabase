require 'spec_helper'

describe "Notices" do
  ['n', 'N'].each do |base_path_fragment|
    it "routes /#{base_path_fragment}/notice_id to NoticesController#show" do
      expect(get: "/#{base_path_fragment}/1234").to route_to(
        controller:  "notices",
        action: "show",
        id: "1234"
    )
    end
  end

end
