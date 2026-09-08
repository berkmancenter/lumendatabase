require 'rails_helper'

describe 'rake lumen:cleanup_completed_notice_submissions', type: :task do
  it 'clears only completed payloads and staged uploads' do
    completed = create(:notice_submission_request, status: 'completed')
    pending = create(:notice_submission_request, status: 'failed')
    completed_upload = create_upload(completed, 'completed')
    pending_upload = create_upload(pending, 'pending')
    completed_blob_id = completed_upload.file.blob.id
    pending_blob_id = pending_upload.file.blob.id

    task.execute

    expect(completed.reload.payload).to eq({})
    expect(NoticeSubmissionUpload.exists?(completed_upload.id)).to be false
    expect(ActiveStorage::Blob.exists?(completed_blob_id)).to be false
    expect(pending.reload.payload).not_to eq({})
    expect(NoticeSubmissionUpload.exists?(pending_upload.id)).to be true
    expect(ActiveStorage::Blob.exists?(pending_blob_id)).to be true
  end

  def create_upload(submission_request, key)
    upload = submission_request.uploads.create!(
      parameter_key: key,
      kind: 'supporting',
      original_filename: "#{key}.txt",
      content_type: 'text/plain',
      byte_size: key.bytesize,
      checksum: Digest::SHA256.hexdigest(key)
    )
    upload.file.attach(
      io: StringIO.new(key),
      filename: "#{key}.txt",
      content_type: 'text/plain'
    )
    upload
  end
end
