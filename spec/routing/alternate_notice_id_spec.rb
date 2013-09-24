require 'spec_helper'

describe "Alternate Notice IDs" do
  it "routes /submission_id/1234 to SubmissionId#show" do
    expect(get: "/submission_id/1234").to route_to(
      controller:  "submission_ids",
      action: "show",
      id: "1234"
    )
  end

  it "routes /original_notice_id/1234 to OriginalNoticeId#show" do
    expect(get: "/original_notice_id/1234").to route_to(
      controller:  "original_notice_ids",
      action: "show",
      id: "1234"
    )
  end
end
