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

describe "Submitters" do
  %w( Twitter Google twitter google ).each do |submitter|
    it "routes /#{submitter} to a search on that recipient name" do
      expect(get: "/#{submitter}").to route_to(
        controller: "notices/search",
        action: "index",
        recipient_name: submitter
      )
    end

    it "routes /#{submitter}/Topic to a search on that recipient/topic" do
      expect(get: "/#{submitter}/Defamation").to route_to(
        controller: "notices/search",
        action: "index",
        recipient_name: submitter,
        topics: "Defamation"
      )
    end
  end

  it "only supports Twitter and Google" do
    expect(get: "/Other").not_to be_routable
    expect(get: "/Other/Whatever").not_to be_routable
  end
end

