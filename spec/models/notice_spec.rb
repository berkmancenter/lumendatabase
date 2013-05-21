require 'spec_helper'

describe Notice do
  it { should validate_presence_of :title }

  context "#notice_file_content" do
    it "returns the contents of its uploaded notice file when present" do
      notice = create(:notice_with_notice_file, content: "Some content")

      expect(notice.notice_file_content).to eq "Some content"
    end

    it "returns an empty string when there is no uploaded file" do
      notice = build(:notice)

      expect(notice.notice_file_content).to eq ''
    end
  end
end
