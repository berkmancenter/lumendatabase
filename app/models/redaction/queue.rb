module Redaction
  class Queue
    attr_reader :user, :notices

    def self.queue_max
      15
    end

    def initialize(user)
      @user = user
      @notices = scoped_notices
    end

    def reload
      @notices = scoped_notices
    end

    def release(notice_ids)
      update_all(notice_ids, reviewer_id: nil)
    end

    def mark_as_spam(notice_ids)
      update_all(notice_ids, reviewer_id: nil, spam: true)
    end

    def hide(notice_ids)
      update_all(notice_ids, reviewer_id: nil, hidden: true)
    end

    def available_space
      self.class.queue_max - notices.count
    end

    def full?
      available_space.zero?
    end

    def empty?
      available_space == self.class.queue_max
    end

    private

    def update_all(notice_ids, updates)
      scoped_notices.where(id: notice_ids).update_all(updates)
    end

    def scoped_notices
      Notice.in_review(user)
    end
  end
end
