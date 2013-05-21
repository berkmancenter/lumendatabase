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

  context "#recent" do
    it "returns notices sent in the past week" do
      recent_notice = create(:notice, date_sent: 1.week.ago + 1.hour)
      old_notice = create(:notice, date_sent: 1.week.ago - 1.hour)

      expect(Notice.recent).to include(recent_notice)
      expect(Notice.recent).not_to include(old_notice)
    end

    it "returns notices in descending date sent order" do
      third_notice = create(:notice, date_sent: 16.hours.ago)
      first_notice = create(:notice, date_sent: 1.hour.ago)
      second_notice = create(:notice, date_sent: 10.hours.ago)

      expect(Notice.recent).to eq [first_notice, second_notice, third_notice]
    end
  end
end
