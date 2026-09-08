require 'rails_helper'

RSpec.describe NoticeSubmissionRequest, type: :model do
  it 'requires a payload until processing is completed' do
    submission_request = build(:notice_submission_request, payload: {})

    expect(submission_request).not_to be_valid

    submission_request.status = 'completed'

    expect(submission_request).to be_valid
  end

  it 'finds new, due failed, and stale queued or processing submissions for dispatch' do
    received = create(:notice_submission_request, status: 'received')
    failed = create(
      :notice_submission_request,
      status: 'failed',
      attempts: 2,
      next_attempt_at: 1.minute.ago
    )
    staging_failed = create(
      :notice_submission_request,
      status: 'staging_failed',
      attempts: 1,
      next_attempt_at: 1.minute.ago
    )
    stale_processing = create(
      :notice_submission_request,
      status: 'processing',
      started_at: described_class::PROCESSING_TIMEOUT.ago - 1.minute
    )
    stale_queued = create(
      :notice_submission_request,
      status: 'queued',
      queued_at: described_class::QUEUED_TIMEOUT.ago - 1.minute
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
    create(
      :notice_submission_request,
      status: 'failed',
      attempts: NoticeSubmissionRequest::MAX_ATTEMPTS
    )
    create(:notice_submission_request, status: 'completed')

    expect(described_class.dispatchable)
      .to contain_exactly(
        received,
        failed,
        staging_failed,
        stale_queued,
        stale_processing
      )
  end

  it 'resolves the notice created with its reserved ID' do
    submission_request = create(:notice_submission_request)
    notice = create(:dmca, id: submission_request.reserved_notice_id)

    expect(submission_request.notice).to eq(notice)
  end

  it 'discards rolled-back changes before recording a failure' do
    submission_request = create(:notice_submission_request)
    submission_request.assign_attributes(
      status: 'processing',
      started_at: Time.current
    )

    expect do
      submission_request.mark_failed!(StandardError.new('processor failed'))
    end.not_to raise_error

    submission_request.reload
    expect(submission_request).to be_failed
    expect(submission_request.attempts).to eq(1)
    expect(submission_request.started_at).to be_nil
    expect(submission_request.failure_class).to eq('StandardError')
    expect(submission_request.failure_message).to eq('processor failed')
    expect(submission_request.next_attempt_at).to be > Time.current
  end

  it 'does not replace a concurrently completed status with a failure' do
    submission_request = create(
      :notice_submission_request,
      status: 'completed'
    )
    submission_request.status = 'processing'

    submission_request.mark_failed!(StandardError.new('late failure'))

    expect(submission_request.reload).to be_completed
    expect(submission_request.failure_message).to be_nil
  end

  it 'stops scheduling retries after the maximum attempt count' do
    submission_request = create(
      :notice_submission_request,
      attempts: described_class::MAX_ATTEMPTS - 1
    )

    submission_request.mark_failed!(StandardError.new('still failing'))

    submission_request.reload
    expect(submission_request.attempts).to eq(described_class::MAX_ATTEMPTS)
    expect(submission_request.next_attempt_at).to be_nil
    expect(described_class.dispatchable).not_to include(submission_request)
  end

  it 'allows only a queued or received submission to begin processing' do
    queued = create(:notice_submission_request, status: 'queued')

    expect(queued.begin_processing!).to be true
    expect(queued.reload.status).to eq('processing')
    expect(queued.started_at).to be_present
    expect(queued.begin_processing!).to be false
  end
end
