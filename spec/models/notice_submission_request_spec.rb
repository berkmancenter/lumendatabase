require 'rails_helper'

RSpec.describe NoticeSubmissionRequest, type: :model do
  it 'finds pending and retryable failed submissions for dispatch' do
    pending = create(:notice_submission_request)
    failed = create(
      :notice_submission_request,
      status: 'failed',
      attempts: 2,
      queued_at: 10.minutes.ago
    )
    staging_failed = create(
      :notice_submission_request,
      status: 'staging_failed',
      attempts: 1,
      queued_at: 10.minutes.ago
    )
    create(:notice_submission_request, queued_at: Time.current)
    create(
      :notice_submission_request,
      status: 'failed',
      attempts: NoticeSubmissionRequest::MAX_ATTEMPTS
    )
    create(:notice_submission_request, status: 'completed')

    expect(described_class.dispatchable)
      .to contain_exactly(pending, failed, staging_failed)
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
end
