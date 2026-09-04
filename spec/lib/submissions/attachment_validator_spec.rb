require 'rails_helper'
require 'base64'

RSpec.describe Lumen::Submissions::AttachmentValidator do
  it 'accepts valid attachments without writing files' do
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
  end

  it 'rejects invalid attachment data and kinds' do
    errors = ActiveModel::Errors.new(Object.new)
    payload = {
      file_uploads_attributes: [{
        kind: 'invalid',
        file: 'data:text/plain;base64,not-base64!',
        file_name: 'broken.txt'
      }]
    }

    expect(described_class.new(payload).validate(errors)).to be false
    expect(errors[:file_uploads]).to include(/kind/)
    expect(errors[:file_uploads]).to include(/invalid base64/)
  end
end
