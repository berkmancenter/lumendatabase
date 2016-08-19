require 'spec_helper'

describe Redaction::Queue do
  FAKE_QUEUE_MAX = 2

  before { allow(Redaction::Queue).to receive(:queue_max).and_return(FAKE_QUEUE_MAX) }

  context '#notices' do
    it "returns the notices in review with the user" do
      user = User.new
      expect(Notice).to receive(:in_review).with(user).and_return(:some_notices)

      queue = new_queue(user)

      expect(queue.notices).to eq :some_notices
    end
  end

  context "#reload" do
    it "reloads the in-review notices" do
      stub_notices_in_review(3)
      queue = new_queue
      notices_before = queue.notices
      stub_notices_in_review(2)

      queue.reload

      expect(queue.notices).not_to eq notices_before
    end
  end

  context "bulk actions" do
    %i( release mark_as_spam hide ).each do |action|
      it "accepts nil parameters to ##{action}" do
        expect { new_queue.send(action, nil) }.not_to raise_error
      end
    end

    context "#release" do
      it "updates reviewer_id to nil for the passed notice ids" do
        queue = new_queue(create(:user))
        notice = notice_in_review(queue.user)
        notices = notices_in_review(queue.user, 2)

        act_and_reload(queue, :release, notices)

        expect(notices).to be_all { |n| n.reviewer.nil? }
        expect(notice.reviewer).to eq queue.user
      end

      it "ignores notices not in my queue" do
        queue = new_queue(create(:user))
        notice = notice_in_review(queue.user)
        other_user = create(:user)
        other_notice = notice_in_review(other_user)

        act_and_reload(queue, :release, [notice, other_notice])

        expect(notice.reviewer).to be_nil
        expect(other_notice.reviewer).to eq other_user
      end
    end

    context "#mark_as_spam" do
      it "updates spam to true and releases the passed notice ids" do
        queue = new_queue(create(:user))
        notice = notice_in_review(queue.user)
        notices = notices_in_review(queue.user, 2)

        act_and_reload(queue, :mark_as_spam, notices)

        expect(notices).to be_all(&:spam)
        expect(notice).not_to be_spam
        expect(notices).to be_all { |n| n.reviewer.nil? }
        expect(notice.reviewer).to eq queue.user
      end

      it "ignores notices not in my queue" do
        queue = new_queue(create(:user))
        notice = notice_in_review(queue.user)
        other_user = create(:user)
        other_notice = notice_in_review(other_user)

        act_and_reload(queue, :mark_as_spam, [notice, other_notice])

        expect(notice).to be_spam
        expect(other_notice).not_to be_spam
        expect(notice.reviewer).to be_nil
        expect(other_notice.reviewer).to eq other_user
      end
    end

    context "#hide" do
      it "updates hidden to true and releases the passed notice ids" do
        queue = new_queue(create(:user))
        notice = notice_in_review(queue.user)
        notices = notices_in_review(queue.user, 2)

        act_and_reload(queue, :hide, notices)

        expect(notices).to be_all(&:hidden)
        expect(notice).not_to be_hidden
        expect(notices).to be_all { |n| n.reviewer.nil? }
        expect(notice.reviewer).to eq queue.user
      end

      it "ignores notices not in my queue" do
        queue = new_queue(create(:user))
        notice = notice_in_review(queue.user)
        other_user = create(:user)
        other_notice = notice_in_review(other_user)

        act_and_reload(queue, :hide, [notice, other_notice])

        expect(notice).to be_hidden
        expect(other_notice).not_to be_hidden
        expect(notice.reviewer).to be_nil
        expect(other_notice.reviewer).to eq other_user
      end
    end

    private

    def notice_in_review(user)
      create(:dmca, review_required: true, reviewer: user)
    end

    def notices_in_review(user, n)
      n.times.map { notice_in_review(user) }
    end

    def act_and_reload(queue, action, notices)
      queue.send(action, notices)
      notices.each(&:reload)
    end
  end

  context "#available_space" do
    it "returns the amount of space in the queue" do
      stub_notices_in_review(FAKE_QUEUE_MAX - 1)
      queue = new_queue

      expect(queue.available_space).to eq 1
    end
  end

  context '#full?/#empty?' do
    it "returns true/false when the queue is full" do
      stub_notices_in_review(FAKE_QUEUE_MAX)
      queue = new_queue

      expect(queue).to be_full
      expect(queue).not_to be_empty
    end

    it "returns false/false when the queue is partially full" do
      stub_notices_in_review(FAKE_QUEUE_MAX - 1)
      queue = new_queue

      expect(queue).not_to be_full
      expect(queue).not_to be_empty
    end

    it "returns false/true when the queue is empty" do
      stub_notices_in_review(0)
      queue = new_queue

      expect(queue).not_to be_full
      expect(queue).to be_empty
    end
  end

  private

  def stub_notices_in_review(n)
    notices = Array.new(n) { Notice.new }
    allow(Notice).to receive(:in_review).and_return(notices)
  end

  def new_queue(user = User.new)
    Redaction::Queue.new(user)
  end

end
