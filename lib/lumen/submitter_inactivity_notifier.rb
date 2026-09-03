# frozen_string_literal: true

module Lumen
  class SubmitterInactivityNotifier
    def self.call(now: Time.current)
      new(now: now).call
    end

    def initialize(now: Time.current)
      @now = now
    end

    def call
      Entity
        .where.not(inactivity_notification_emails: [nil, ''])
        .where.not(inactivity_notification_after_hours: nil)
        .find_each
        .count { |entity| notify(entity) }
    end

    private

    def notify(entity)
      last_submission_at = entity.latest_submission_at
      return false unless entity.inactivity_notification_due?(
        @now,
        last_submission_at: last_submission_at
      )

      SubmitterInactivityMailer
        .inactivity_notification(entity, last_submission_at)
        .deliver_later

      entity.update_columns(inactivity_notification_sent_at: @now)

      true
    end
  end
end
