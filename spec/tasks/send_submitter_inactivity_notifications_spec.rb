require 'rails_helper'

describe 'rake lumen:send_submitter_inactivity_notifications', type: :task do
  let(:now) { Time.zone.local(2026, 9, 2, 12) }

  before do
    ActionMailer::Base.deliveries.clear
    Timecop.freeze(now)
  end

  after { Timecop.return }

  it 'notifies every configured address after the inactivity period' do
    submitter = configured_submitter
    create_submission(submitter, at: now - 1.hour)

    expect { task.execute }
      .to change { ActionMailer::Base.deliveries.size }
      .by(1)

    email = ActionMailer::Base.deliveries.last
    expect(email.to).to match_array(%w[first@example.com second@example.com])
    expect(email.subject).to eq('Submitter inactivity alert: Google')
    expect(submitter.reload.inactivity_notification_sent_at).to eq(now)
  end

  it 'does not notify before the inactivity period has elapsed' do
    submitter = configured_submitter
    create_submission(submitter, at: now - 59.minutes)

    expect { task.execute }
      .not_to change { ActionMailer::Base.deliveries.size }
  end

  it 'does not count another entity role as a submission' do
    entity = configured_submitter
    notice = create(:dmca, created_at: now - 2.days)
    create(:entity_notice_role, entity: entity, notice: notice, name: 'sender')

    expect { task.execute }
      .not_to change { ActionMailer::Base.deliveries.size }
  end

  it 'sends once per inactivity period and becomes eligible after a new submission' do
    submitter = configured_submitter
    create_submission(submitter, at: now - 2.hours)

    expect { task.execute }
      .to change { ActionMailer::Base.deliveries.size }
      .by(1)
    expect { task.execute }
      .not_to change { ActionMailer::Base.deliveries.size }

    next_submission_at = now + 1.hour
    create_submission(submitter, at: next_submission_at)

    Timecop.freeze(next_submission_at + 1.hour)

    expect { task.execute }
      .to change { ActionMailer::Base.deliveries.size }
      .by(1)
  end

  private

  def configured_submitter
    create(
      :entity,
      name: 'Google',
      inactivity_notification_emails: "first@example.com, second@example.com",
      inactivity_notification_after_hours: 1
    )
  end

  def create_submission(submitter, at:)
    Timecop.freeze(at) do
      notice = create(:dmca)
      create(
        :entity_notice_role,
        entity: submitter,
        notice: notice,
        name: 'submitter'
      )
    end
  end
end
