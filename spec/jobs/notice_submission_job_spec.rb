require 'rails_helper'

RSpec.describe NoticeSubmissionJob, type: :job do
  it 'uses the submissions queue' do
    expect(described_class.queue_name).to eq('submissions')
  end

  it 'processes the stored submission' do
    submission_request = create(:notice_submission_request)

    described_class.perform_now(submission_request.id)

    expect(submission_request.reload).to be_completed
    expect(Notice.exists?(submission_request.reserved_notice_id)).to be true
  end

  it 'records a failure without losing the submission data' do
    submission_request = create(:notice_submission_request)
    allow(Lumen::Submissions::Processor).to receive(:new)
      .and_raise(StandardError, 'boom')

    expect do
      described_class.perform_now(submission_request.id)
    end.to raise_error(StandardError, 'boom')

    submission_request.reload
    expect(submission_request).to be_failed
    expect(submission_request.attempts).to eq(1)
    expect(submission_request.failure_message).to eq('boom')
    expect(submission_request.payload).to be_present
  end

  it 'records attachment staging failures for retry' do
    submission_request = create(:notice_submission_request)
    allow(Lumen::Submissions::AttachmentStager).to receive(:new)
      .and_raise(IOError, 'storage unavailable')

    expect do
      described_class.perform_now(submission_request.id)
    end.to raise_error(IOError, 'storage unavailable')

    submission_request.reload
    expect(submission_request.status).to eq('staging_failed')
    expect(submission_request.attempts).to eq(1)
    expect(submission_request.payload).to be_present
  end
end
