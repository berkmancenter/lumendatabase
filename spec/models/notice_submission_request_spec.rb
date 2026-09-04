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
end
