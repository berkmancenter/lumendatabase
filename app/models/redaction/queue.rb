module Redaction
  class Queue
    def self.queue_max
      15
    end

    def initialize(user)
      @user = user
    end

    def fill
      return if full?

      Notice.available_for_review(space).update_all(reviewer_id: @user)
    end

    def full?
      space.zero?
    end

    def notices
      @notices ||= Notice.in_review(@user)
    end

    private

    def space
      self.class.queue_max - notices.count
    end
  end
end
