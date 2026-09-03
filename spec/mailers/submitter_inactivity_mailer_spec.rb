require 'rails_helper'

describe SubmitterInactivityMailer, type: :mailer do
  describe '#inactivity_notification' do
    let(:submitter) do
      create(
        :entity,
        name: 'Google',
        inactivity_notification_emails: "first@example.com\nsecond@example.com",
        inactivity_notification_after_hours: 1
      )
    end
    let(:last_submission_at) { Time.zone.local(2026, 9, 1, 10, 30) }
    let(:mail) do
      described_class
        .inactivity_notification(submitter, last_submission_at)
        .deliver_now
    end

    it 'addresses every configured recipient and identifies the submitter' do
      expect(mail.to).to match_array(%w[first@example.com second@example.com])
      expect(mail.subject).to eq('Submitter inactivity alert: Google')
      expect(mail.body.encoded).to include(
        'Google has not submitted a notice to Lumen recently.'
      )
      expect(mail.body.encoded).to include(
        "Last submission: #{last_submission_at.to_fs(:long)}"
      )
      expect(mail.body.encoded).to include('Notification threshold: 1 hour')
    end
  end
end
