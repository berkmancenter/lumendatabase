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
    expect(submission_request.status).to eq('pending')
    expect(submission_request.payload).to eq(payload.deep_stringify_keys)
    expect(submission_request.submitted_by).to eq(user)
    expect(submission_request.submitter_entity).to eq(user.entity)
    expect(submission_request.reserved_notice_id).to be_positive
    expect(Notice.exists?(submission_request.reserved_notice_id)).to be false
  end

  it 'stores attachment data in the receipt without staging it synchronously' do
    bytes = "attachment\x00contents".b
    payload[:file_uploads_attributes] = [{
      kind: 'original',
      file: "data:application/octet-stream;base64,#{Base64.encode64(bytes)}",
      file_name: 'original.bin'
    }]

    submission_request = intake.call

    expect(submission_request.payload.dig('file_uploads_attributes', 0, 'file'))
      .to start_with('data:application/octet-stream;base64,')
    expect(submission_request.uploads).to be_empty
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

  def intake(supplied_payload: payload)
    described_class.new(
      notice_type: DMCA,
      payload: supplied_payload,
      submitted_by: user,
      request_id: 'request-id'
    )
  end
end
