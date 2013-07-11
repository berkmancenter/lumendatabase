module Redaction
  class Queue
    attr_reader :user, :notices

    def self.queue_max
      15
    end

    def initialize(user)
      @user = user
      @notices = Notice.in_review(@user)
    end

    def reload
      @notices = Notice.in_review(user)
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
  end
end
