require 'rails_helper'

RSpec.describe NoticeSubmissionDispatchJob, type: :job do
  it 'enqueues each dispatchable submission' do
    stale_queued_at = 10.minutes.ago
    pending = create(
      :notice_submission_request,
      queued_at: stale_queued_at
    )
    failed = create(
      :notice_submission_request,
      status: 'failed',
      queued_at: stale_queued_at
    )
    create(:notice_submission_request, status: 'completed')
    enqueued_request_ids = []
    expect(NoticeSubmissionJob).to receive(:perform_later).twice do |request_id|
      enqueued_request_ids << request_id
      expect(NoticeSubmissionRequest.find(request_id).queued_at)
        .to be > stale_queued_at
    end

    described_class.perform_now

    expect(enqueued_request_ids).to contain_exactly(pending.id, failed.id)
    expect(pending.reload.queued_at).to be_present
    expect(failed.reload.queued_at).to be_present
  end
end
