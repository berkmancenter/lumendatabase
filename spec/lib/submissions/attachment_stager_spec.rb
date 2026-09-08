require 'rails_helper'
require 'base64'

RSpec.describe Lumen::Submissions::AttachmentStager do
  let(:bytes) { "attachment\x00contents".b }
  let(:payload) do
    attributes_for(:notice_submission_request)[:payload].merge(
      'file_uploads_attributes' => [{
        'kind' => 'original',
        'file' => "data:application/octet-stream;base64,#{Base64.encode64(bytes)}",
        'file_name' => 'original.bin'
      }]
    )
  end
  let(:submission_request) do
    create(:notice_submission_request, payload: payload)
  end

  it 'copies attachment bytes from the durable receipt to storage' do
    described_class.new(submission_request).stage
    upload = submission_request.uploads.first

    expect(upload.file.download).to eq(bytes)
    expect(upload.original_filename).to eq('original.bin')
    expect(upload.content_type).to eq('application/octet-stream')
    expect(upload.byte_size).to eq(bytes.bytesize)
    expect(upload.checksum).to eq(Digest::SHA256.hexdigest(bytes))
    expect(submission_request.payload.dig('file_uploads_attributes', 0, 'file'))
      .to be_present
  end

  it 'does not duplicate successfully staged attachments' do
    stager = described_class.new(submission_request)
    stager.stage

    expect { stager.stage }
      .not_to change(NoticeSubmissionUpload, :count)
  end

  it 'restages attachments after a staging failure' do
    stager = described_class.new(submission_request)
    stager.stage
    submission_request.mark_staging_failed!(IOError.new('corrupt upload'))

    expect { stager.stage }
      .not_to change(NoticeSubmissionUpload, :count)
    expect(submission_request.reload.status).to eq('processing')
    expect(submission_request.uploads.first.file.download).to eq(bytes)
  end

  it 'leaves the durable payload intact when staging fails' do
    allow_any_instance_of(ActiveStorage::Attached::One).to receive(:attach)
      .and_raise(IOError, 'storage unavailable')

    expect { described_class.new(submission_request).stage }
      .to raise_error(IOError, 'storage unavailable')

    expect(submission_request.reload.payload).to eq(payload)
    expect(submission_request.uploads).to be_empty
  end

  it 'enforces resource limits again before staging a stored payload' do
    stub_const('Lumen::Submissions::Attachment::MAX_ATTACHMENT_BYTES', 4)

    expect { described_class.new(submission_request).stage }
      .to raise_error(
        Lumen::Submissions::Attachment::InvalidAttachment,
        /4 bytes per-file limit/
      )

    expect(submission_request.reload.payload).to eq(payload)
    expect(submission_request.uploads).to be_empty
  end

  it 'enforces resource limits on attachments staged by an older attempt' do
    stager = described_class.new(submission_request)
    stager.stage
    stub_const('Lumen::Submissions::Attachment::MAX_ATTACHMENT_BYTES', 4)

    expect { stager.stage }
      .to raise_error(
        Lumen::Submissions::Attachment::InvalidAttachment,
        /4 bytes per-file limit/
      )
  end
end
