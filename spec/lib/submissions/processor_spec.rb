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

  it 'copies staged attachments into the final notice' do
    bytes = "original\x00document".b
    payload = attributes_for(:notice_submission_request)[:payload].merge(
      'file_uploads_attributes' => [{
        'kind' => 'original',
        'file' => "data:application/octet-stream;base64,#{Base64.encode64(bytes)}",
        'file_name' => 'original.bin'
      }]
    )
    submission_request = Lumen::Submissions::Intake.new(
      notice_type: DMCA,
      payload: payload,
      submitted_by: nil
    ).call
    Lumen::Submissions::AttachmentStager.new(submission_request).stage

    notice = described_class.new(submission_request).process

    expect(File.binread(notice.original_documents.first.file.path)).to eq(bytes)
    expect(notice.original_documents.first.file_file_name).to eq('original.bin')
  end

  it 'defaults a blank attachment kind before creating the notice' do
    bytes = 'supporting document'
    payload = attributes_for(:notice_submission_request)[:payload].merge(
      'file_uploads_attributes' => [{
        'kind' => '',
        'file' => "data:text/plain;base64,#{Base64.strict_encode64(bytes)}",
        'file_name' => 'supporting.txt'
      }]
    )
    submission_request = Lumen::Submissions::Intake.new(
      notice_type: DMCA,
      payload: payload,
      submitted_by: nil
    ).call
    Lumen::Submissions::AttachmentStager.new(submission_request).stage

    notice = described_class.new(submission_request).process

    expect(notice.file_uploads.first.kind).to eq('supporting')
  end

  it 'refuses to create a notice from a corrupted staged attachment' do
    bytes = 'original document'
    payload = attributes_for(:notice_submission_request)[:payload].merge(
      'file_uploads_attributes' => [{
        'kind' => 'original',
        'file' => "data:text/plain;base64,#{Base64.strict_encode64(bytes)}",
        'file_name' => 'original.txt'
      }]
    )
    submission_request = Lumen::Submissions::Intake.new(
      notice_type: DMCA,
      payload: payload,
      submitted_by: nil
    ).call
    Lumen::Submissions::AttachmentStager.new(submission_request).stage
    submission_request.uploads.first.update_column(
      :checksum,
      Digest::SHA256.hexdigest('different bytes')
    )

    expect do
      described_class.new(submission_request).process
    end.to raise_error(
      described_class::StagedAttachmentError,
      /Checksum mismatch/
    )

    expect(Notice.exists?(submission_request.reserved_notice_id)).to be false
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
end
