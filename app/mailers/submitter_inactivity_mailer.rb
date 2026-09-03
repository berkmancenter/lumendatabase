# frozen_string_literal: true

class SubmitterInactivityMailer < ApplicationMailer
  def inactivity_notification(submitter, last_submission_at)
    @submitter = submitter
    @last_submission_at = last_submission_at
    @inactivity_hours = submitter.inactivity_notification_after_hours

    mail(
      to: submitter.inactivity_notification_recipients,
      subject: "Submitter inactivity alert: #{submitter.name}"
    )
  end
end
