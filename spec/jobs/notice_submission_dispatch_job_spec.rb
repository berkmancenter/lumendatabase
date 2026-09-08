require 'rails_helper'

RSpec.describe NoticeSubmissionDispatchJob, type: :job do
  it 'enqueues only due and recoverable submissions' do
    received = create(
      :notice_submission_request,
      status: 'received'
    )
    failed = create(
      :notice_submission_request,
      status: 'failed',
      next_attempt_at: 1.minute.ago
    )
    stale_processing = create(
      :notice_submission_request,
      status: 'processing',
      started_at: NoticeSubmissionRequest::PROCESSING_TIMEOUT.ago - 1.minute
    )
    stale_queued = create(
      :notice_submission_request,
      status: 'queued',
      queued_at: NoticeSubmissionRequest::QUEUED_TIMEOUT.ago - 1.minute
    )
    create(
      :notice_submission_request,
      status: 'queued',
      queued_at: Time.current
    )
    create(
      :notice_submission_request,
      status: 'failed',
      next_attempt_at: 1.hour.from_now
    )
    create(
      :notice_submission_request,
      status: 'processing',
      started_at: Time.current
    )
    create(:notice_submission_request, status: 'completed')
    enqueued_request_ids = []
    expect(NoticeSubmissionJob).to receive(:perform_later).exactly(4).times do |request_id|
      enqueued_request_ids << request_id
      queued_request = NoticeSubmissionRequest.find(request_id)
      expect(queued_request.status).to eq('queued')
      expect(queued_request.queued_at).to be_present
    end

    described_class.perform_now
    described_class.perform_now

    expect(enqueued_request_ids).to contain_exactly(
      received.id,
      failed.id,
      stale_queued.id,
      stale_processing.id
    )
    expect(received.reload.status).to eq('queued')
    expect(failed.reload.status).to eq('queued')
    expect(stale_queued.reload.queued_at).to be >
      NoticeSubmissionRequest::QUEUED_TIMEOUT.ago
    expect(stale_processing.reload.status).to eq('queued')
  end

  it 'leaves a receipt dispatchable when enqueueing fails' do
    received = create(:notice_submission_request, status: 'received')
    allow(NoticeSubmissionJob).to receive(:perform_later)
      .and_raise(RedisClient::CannotConnectError, 'redis unavailable')
    allow(Rails.logger).to receive(:error)

    described_class.perform_now

    received.reload
    expect(received.status).to eq('received')
    expect(received.queued_at).to be_nil
    expect(received).to be_dispatchable_now
  end
end
