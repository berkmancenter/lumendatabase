require 'rails_helper'
require 'base64'

RSpec.describe Lumen::Submissions::AttachmentValidator do
  it 'accepts valid attachments without persisting files' do
    errors = ActiveModel::Errors.new(Object.new)
    payload = {
      file_uploads_attributes: [{
        kind: 'original',
        file: "data:text/plain;base64,#{Base64.strict_encode64('saved')}",
        file_name: 'saved.txt'
      }]
    }

    expect(described_class.new(payload).validate(errors)).to be true
    expect(errors).to be_empty
    expect(ActiveStorage::Blob.count).to eq(0)
    expect(FileUpload.count).to eq(0)
  end

  it 'rejects invalid attachment data' do
    errors = ActiveModel::Errors.new(Object.new)
    payload = {
      file_uploads_attributes: [{
        kind: 'supporting',
        file: 'data:text/plain;base64,not-base64!',
        file_name: 'broken.txt'
      }]
    }

    expect(described_class.new(payload).validate(errors)).to be false
    expect(errors[:file_uploads]).to include(/invalid base64/)
  end

  it 'runs the FileUpload model validations' do
    errors = ActiveModel::Errors.new(Object.new)
    payload = {
      file_uploads_attributes: [{
        kind: 'invalid',
        file: "data:text/plain;base64,#{Base64.strict_encode64('plain text')}",
        file_name: 'attachment.txt'
      }]
    }

    expect(described_class.new(payload).validate(errors)).to be false
    expect(errors[:file_uploads]).to include(/Kind.*included/)
  end

  it 'runs the Paperclip media type spoof validation' do
    errors = ActiveModel::Errors.new(Object.new)
    payload = {
      file_uploads_attributes: [{
        kind: 'supporting',
        file: "data:text/plain;base64,#{Base64.strict_encode64('plain text')}",
        file_name: 'something.jpg'
      }]
    }

    expect(described_class.new(payload).validate(errors)).to be false
    expect(errors[:file_uploads]).to include(/contents.*reported/)
  end

  it 'rejects more than the maximum attachment count before decoding' do
    stub_const('Lumen::Submissions::Attachment::MAX_ATTACHMENTS', 2)
    errors = ActiveModel::Errors.new(Object.new)
    payload = {
      file_uploads_attributes: Array.new(3) do
        {
          kind: 'supporting',
          file: 'data:text/plain;base64,not-decoded',
          file_name: 'attachment.txt'
        }
      end
    }

    expect(described_class.new(payload).validate(errors)).to be false
    expect(errors[:file_uploads]).to include(/more than 2 attachments/)
  end

  it 'rejects an attachment over the per-file size limit' do
    stub_const('Lumen::Submissions::Attachment::MAX_ATTACHMENT_BYTES', 4)
    errors = ActiveModel::Errors.new(Object.new)
    payload = {
      file_uploads_attributes: [{
        kind: 'supporting',
        file: "data:text/plain;base64,#{Base64.strict_encode64('12345')}",
        file_name: 'attachment.txt'
      }]
    }

    expect(described_class.new(payload).validate(errors)).to be false
    expect(errors[:file_uploads]).to include(/4 bytes per-file limit/)
  end

  it 'rejects attachments over the total size limit' do
    stub_const('Lumen::Submissions::Attachment::MAX_ATTACHMENT_BYTES', 5)
    stub_const('Lumen::Submissions::Attachment::MAX_TOTAL_ATTACHMENT_BYTES', 7)
    errors = ActiveModel::Errors.new(Object.new)
    payload = {
      file_uploads_attributes: Array.new(2) do
        {
          kind: 'supporting',
          file: "data:text/plain;base64,#{Base64.strict_encode64('1234')}",
          file_name: 'attachment.txt'
        }
      end
    }

    expect(described_class.new(payload).validate(errors)).to be false
    expect(errors[:file_uploads]).to include(/larger than 7 bytes in total/)
  end
end
