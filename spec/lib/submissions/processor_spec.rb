require 'rails_helper'
require 'base64'

RSpec.describe Lumen::Submissions::Processor do
  it 'creates and completes the notice using the reserved ID' do
    submission_request = create(:notice_submission_request)

    notice = described_class.new(submission_request).process

    expect(notice.id).to eq(submission_request.reserved_notice_id)
    expect(notice.title).to eq('A queued notice')
    expect(notice.works.first.description).to eq('A work')
    expect(submission_request.reload.status).to eq('completed')
    expect(submission_request.completed_at).to be_present
    expect(submission_request.payload).to eq({})
  end

  it 'uses the submitter entity captured when the request was accepted' do
    submitter = create(:entity, name: 'Captured Submitter')
    submission_request = create(
      :notice_submission_request,
      submitter_entity: submitter
    )

    notice = described_class.new(submission_request).process

    expect(notice.submitter).to eq(submitter)
  end

  it 'hands the stored attachments to the notice it creates' do
    bytes = "original\x00document".b
    submission_request = create(
      :notice_submission_request,
      file_uploads: [file_upload_for(bytes, 'original', 'original.bin')]
    )
    stored_upload = submission_request.file_uploads.first

    notice = described_class.new(submission_request).process

    original_document = notice.original_documents.first
    expect(original_document).to eq(stored_upload)
    expect(original_document.file_file_name).to eq('original.bin')
    expect(File.binread(original_document.file.path)).to eq(bytes)
    expect(stored_upload.reload.notice_submission_request_id).to be_nil
    expect(submission_request.reload.file_uploads).to be_empty
  end

  it 'is idempotent when the same request is processed twice' do
    submission_request = create(:notice_submission_request)
    processor = described_class.new(submission_request)

    first_notice = processor.process

    expect { processor.process }.not_to change(Notice, :count)
    expect(processor.process).to eq(first_notice)
    expect(submission_request.reload.attempts).to eq(1)
  end

  it 'rolls back notice creation when finalization raises' do
    submission_request = create(:notice_submission_request)
    allow_any_instance_of(DMCA).to receive(:mark_for_review)
      .and_raise(StandardError, 'review failed')

    expect do
      described_class.new(submission_request).process
    end.to raise_error(StandardError, 'review failed')

    expect(Notice.exists?(submission_request.reserved_notice_id)).to be false
    expect(submission_request.reload.status).to eq('queued')
  end

  it 'keeps the attachments with the receipt when the notice is not created' do
    submission_request = create(
      :notice_submission_request,
      file_uploads: [file_upload_for('supporting', 'supporting', 'file.txt')]
    )
    allow_any_instance_of(DMCA).to receive(:mark_for_review)
      .and_raise(StandardError, 'review failed')

    expect do
      described_class.new(submission_request).process
    end.to raise_error(StandardError, 'review failed')

    expect(Notice.exists?(submission_request.reserved_notice_id)).to be false
    expect(submission_request.reload.file_uploads.count).to eq(1)
  end

  private

  def file_upload_for(bytes, kind, file_name)
    file_upload = FileUpload.new(kind: kind, file_name: file_name)
    file_upload.file =
      "data:application/octet-stream;base64,#{Base64.strict_encode64(bytes)}"
    file_upload
  end
end
