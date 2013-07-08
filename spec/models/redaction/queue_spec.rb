require 'spec_helper'

describe Redaction::Queue do
  FAKE_QUEUE_MAX = 2

  before { Redaction::Queue.stub(:queue_max).and_return(FAKE_QUEUE_MAX) }

  context '#fill' do
    it "fills only from available notices" do
      user_one, user_two = create_list(:user, 2)
      expected_notices = create_list(:notice, 2, review_required: true)
      create(:notice, review_required: true, reviewer: user_one)
      create(:notice, review_required: false)
      queue = Redaction::Queue.new(user_two)

      queue.fill

      expect(queue.notices).to match_array(expected_notices)
    end

    it "does not over-fill" do
      create_list(:notice, FAKE_QUEUE_MAX + 1, review_required: true)
      queue = Redaction::Queue.new(create(:user))

      queue.fill

      expect(queue).to be_full
      expect(queue.notices.length).to eq FAKE_QUEUE_MAX
    end
  end

  context '#full?' do
    it "returns true when the queue is full" do
      queue = queue_with_notices(build_list(:notice, FAKE_QUEUE_MAX))

      expect(queue).to be_full
    end

    it "returns false when the queue is not full" do
      queue = queue_with_notices(build_list(:notice, FAKE_QUEUE_MAX - 1))

      expect(queue).not_to be_full
    end
  end

  context '#notices' do
    it "returns the notices for the queue_items" do
      notices = build_list(:notice, 2)
      queue = queue_with_notices(notices)

      expect(queue.notices).to match_array(notices)
    end
  end

  def queue_with_notices(notices)
    user = create(:user)

    notices.each do |notice|
      notice.review_required = true
      notice.reviewer = user
      notice.save!
    end

    Redaction::Queue.new(user)
  end
end
