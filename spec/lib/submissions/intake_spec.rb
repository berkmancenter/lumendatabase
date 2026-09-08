require 'rails_helper'
require 'base64'

RSpec.describe Lumen::Submissions::Intake do
  let(:user) { create(:user, :submitter, :with_entity) }
  let(:payload) do
    {
      title: 'A queued notice',
      works_attributes: [{ description: 'A work' }],
      entity_notice_roles_attributes: [{
        name: 'recipient',
        entity_attributes: { name: 'Recipient' }
      }]
    }
  end

  it 'stores the complete payload and reserves a notice ID' do
    submission_request = intake.call

    expect(submission_request).to be_persisted
    expect(submission_request.status).to eq('received')
    expect(submission_request.payload).to eq(payload.deep_stringify_keys)
    expect(submission_request.submitted_by).to eq(user)
    expect(submission_request.submitter_entity).to eq(user.entity)
    expect(submission_request.queued_at).to be_nil
    expect(submission_request.reserved_notice_id).to be_positive
    expect(Notice.exists?(submission_request.reserved_notice_id)).to be false
  end

  it 'stores attachments as file uploads instead of payload data' do
    bytes = "attachment\x00contents".b
    file_upload = FileUpload.new(kind: 'original', file_name: 'original.bin')
    file_upload.file = data_uri_for('application/octet-stream', bytes)

    submission_request = intake(file_uploads: [file_upload]).call

    expect(submission_request.payload).not_to have_key('file_uploads_attributes')
    stored_upload = submission_request.file_uploads.first
    expect(stored_upload.kind).to eq('original')
    expect(stored_upload.file_file_name).to eq('original.bin')
    expect(File.binread(stored_upload.file.path)).to eq(bytes)
  end

  it 'keeps attachment data out of the payload it stores' do
    payload[:file_uploads_attributes] = [{
      kind: 'original',
      file: data_uri_for('text/plain', 'Original Document'),
      file_name: 'original.txt'
    }]

    submission_request = intake.call

    expect(submission_request.payload).not_to have_key('file_uploads_attributes')
    expect(submission_request.file_uploads).to be_empty
  end

  it 'creates a new receipt and reserved notice ID for every submission' do
    first_submission_request = intake.call
    second_submission_request = intake.call

    expect(second_submission_request).not_to eq(first_submission_request)
    expect(second_submission_request.reserved_notice_id)
      .not_to eq(first_submission_request.reserved_notice_id)
    expect(NoticeSubmissionRequest.count).to eq(2)
  end

  private

  def intake(supplied_payload: payload, file_uploads: [])
    described_class.new(
      notice_type: DMCA,
      payload: supplied_payload,
      submitted_by: user,
      file_uploads: file_uploads,
      request_id: 'request-id'
    )
  end

  def data_uri_for(mime_type, data)
    "data:#{mime_type};base64,#{Base64.strict_encode64(data)}"
  end
end
