require 'rails_helper'

RSpec.describe NoticeSubmissionDispatchJob, type: :job do
  it 'enqueues each dispatchable submission' do
    pending = create(:notice_submission_request)
    failed = create(:notice_submission_request, status: 'failed')
    create(:notice_submission_request, status: 'completed')
    allow(NoticeSubmissionJob).to receive(:perform_later)

    described_class.perform_now

    expect(NoticeSubmissionJob).to have_received(:perform_later).with(pending.id)
    expect(NoticeSubmissionJob).to have_received(:perform_later).with(failed.id)
    expect(pending.reload.queued_at).to be_present
    expect(failed.reload.queued_at).to be_present
  end
end
