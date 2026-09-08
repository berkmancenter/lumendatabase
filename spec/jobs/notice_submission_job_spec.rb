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

  it 'records the original error after the processor transaction rolls back' do
    submission_request = create(:notice_submission_request)
    allow_any_instance_of(DMCA).to receive(:mark_for_review)
      .and_raise(StandardError, 'review failed')

    expect do
      described_class.perform_now(submission_request.id)
    end.to raise_error(StandardError, 'review failed')

    submission_request.reload
    expect(submission_request).to be_failed
    expect(submission_request.attempts).to eq(1)
    expect(submission_request.failure_class).to eq('StandardError')
    expect(submission_request.failure_message).to eq('review failed')
    expect(Notice.exists?(submission_request.reserved_notice_id)).to be false
  end

  it 'preserves the processor error when recording the failure also fails' do
    submission_request = create(:notice_submission_request)
    allow(Lumen::Submissions::Processor).to receive(:new)
      .and_raise(StandardError, 'processor failed')
    allow_any_instance_of(NoticeSubmissionRequest).to receive(:mark_failed!)
      .and_raise(StandardError, 'failure recording failed')
    allow(Rails.logger).to receive(:error)

    expect do
      described_class.perform_now(submission_request.id)
    end.to raise_error(StandardError, 'processor failed')

    expect(Rails.logger).to have_received(:error)
      .with(/failure recording failed/)
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
