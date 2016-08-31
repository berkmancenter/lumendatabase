require 'spec_helper'

describe Redaction::RefillQueue do
  context "#each_input" do
    it "yields an input for each supported profile" do
      inputs = []
      refill = Redaction::RefillQueue.new

      refill.each_input { |input| inputs << input }

      topic_input, submitter_input = inputs
      expect(topic_input.key).to eq :in_topics
      expect(topic_input.label_text).to eq "In topics"
    end
  end

  context "#fill" do
    it "finds notices available for review" do
      notice = create(:dmca, review_required: true)
      queue = new_queue
      refill = Redaction::RefillQueue.new

      refill.fill(queue)

      queue.reload
      expect(queue.notices).to eq [notice]
    end

    it "can be scoped by topic" do
      create(:dmca, :with_topics, review_required: true) # not to be found
      notice = create(:dmca, :with_topics, review_required: true)
      queue = new_queue
      refill = Redaction::RefillQueue.new(notice_scopes: {
        in_topics: [notice.topics.first.id]
      })

      refill.fill(queue)

      queue.reload
      expect(queue.notices).to eq [notice]
    end

    it "can be scoped by submitter" do
      create(:dmca, role_names: %w( submitter ), review_required: true) # not to be found
      notice = create(:dmca, role_names: %w( submitter ), review_required: true)
      queue = new_queue
      refill = Redaction::RefillQueue.new(notice_scopes: {
        submitted_by: [notice.submitter.id]
      })

      refill.fill(queue)

      queue.reload
      expect(queue.notices).to eq [notice]
    end

    it "does not find notices not up for review" do
      create(:dmca, review_required: false)
      queue = new_queue
      refill = Redaction::RefillQueue.new

      refill.fill(queue)

      queue.reload
      expect(queue).to be_empty
    end

    it "does not find other user's notices" do
      create(:dmca, review_required: true, reviewer_id: 1)
      queue = new_queue
      refill = Redaction::RefillQueue.new

      refill.fill(queue)

      queue.reload
      expect(queue).to be_empty
    end

    def new_queue(user = nil)
      user ||= create(:user)
      Redaction::Queue.new(user)
    end
  end
end
