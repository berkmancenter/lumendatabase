require 'spec_helper'
require 'topic_index_queuer'

describe TopicIndexQueuer do
  context ".for" do
    it "updates updated_at for every notice associated with a topic" do
      notice = create(:dmca, :with_topics)
      previous_updated_at = notice.updated_at
      topic = notice.topics.first

      Timecop.travel(1.hour) { described_class.for(topic.id) }
      notice.reload

      expect(notice.updated_at.to_i).not_to eq previous_updated_at.to_i
    end
  end
end
