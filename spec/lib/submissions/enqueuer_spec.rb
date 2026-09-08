require 'rails_helper'

RSpec.describe Lumen::Submissions::Enqueuer do
  it 'marks a due receipt queued before publishing its job' do
    submission_request = create(
      :notice_submission_request,
      status: 'received'
    )
    expect(NoticeSubmissionJob).to receive(:perform_later) do |request_id|
      queued_request = NoticeSubmissionRequest.find(request_id)
      expect(queued_request.status).to eq('queued')
      expect(queued_request.queued_at).to be_present
    end

    expect(described_class.new(submission_request.id).call).to be true

    submission_request.reload
    expect(submission_request.status).to eq('queued')
    expect(submission_request.next_attempt_at).to be_nil
  end

  it 'rolls back the queued state when publishing fails' do
    submission_request = create(
      :notice_submission_request,
      status: 'received'
    )
    allow(NoticeSubmissionJob).to receive(:perform_later)
      .and_raise(RedisClient::CannotConnectError, 'redis unavailable')

    expect do
      described_class.new(submission_request.id).call
    end.to raise_error(RedisClient::CannotConnectError, 'redis unavailable')

    submission_request.reload
    expect(submission_request.status).to eq('received')
    expect(submission_request.queued_at).to be_nil
  end

  it 'treats an Active Job enqueue rejection as a failed publish' do
    submission_request = create(
      :notice_submission_request,
      status: 'received'
    )
    allow(NoticeSubmissionJob).to receive(:perform_later).and_return(false)

    expect do
      described_class.new(submission_request.id).call
    end.to raise_error(described_class::EnqueueError)

    expect(submission_request.reload.status).to eq('received')
    expect(submission_request.queued_at).to be_nil
  end

  it 're-publishes a receipt that has been queued too long' do
    submission_request = create(
      :notice_submission_request,
      status: 'queued',
      queued_at: NoticeSubmissionRequest::QUEUED_TIMEOUT.ago - 1.minute
    )
    expect(NoticeSubmissionJob).to receive(:perform_later)

    expect(described_class.new(submission_request.id).call).to be true
    expect(submission_request.reload.queued_at).to be >
      NoticeSubmissionRequest::QUEUED_TIMEOUT.ago
  end

  it 'does not re-publish a recently queued receipt' do
    submission_request = create(
      :notice_submission_request,
      status: 'queued',
      queued_at: Time.current
    )
    expect(NoticeSubmissionJob).not_to receive(:perform_later)

    expect(described_class.new(submission_request.id).call).to be false
  end

  it 'does not publish a failed receipt before its backoff expires' do
    submission_request = create(
      :notice_submission_request,
      status: 'failed',
      next_attempt_at: 1.hour.from_now
    )
    expect(NoticeSubmissionJob).not_to receive(:perform_later)

    expect(described_class.new(submission_request.id).call).to be false
  end
end
