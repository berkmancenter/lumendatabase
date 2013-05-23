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

  context "tagging" do
    it "accepts a comma-delimited string and turns it into an array of tags" do
      notice = create(:notice, tag_list: 'foo, bar, baz, blee')

      expect(notice.tag_list).to eq ['foo','bar','baz','blee']
    end

    it 'has lowercases tags automatically' do
      notice = create(:notice, tag_list: 'FOO')

      expect(notice.tag_list).to eq ['foo']
    end

    it 'cleans up unused tags after deletion' do
      notice = create(:notice, tag_list: 'foo')
      notice.tag_list.remove('foo')
      notice.save

      expect(ActsAsTaggableOn::Tag.find_by_name('foo')).not_to be
    end
  end
end
