# frozen_string_literal: true

require 'digest'

class Lumen::Submissions::Intake
  def initialize(notice_type:, payload:, submitted_by:, file_uploads: [],
                 request_id: nil)
    @notice_type = notice_type
    @payload = payload.deep_stringify_keys.except('file_uploads_attributes')
    @submitted_by = submitted_by
    @file_uploads = file_uploads
    @request_id = request_id
  end

  def call
    create_request
  end

  private

  attr_reader :file_uploads, :notice_type, :payload, :request_id, :submitted_by

  def create_request
    NoticeSubmissionRequest.create!(
      reserved_notice_id: reserve_notice_id,
      notice_type: notice_type.name,
      payload: payload,
      payload_digest: payload_digest,
      submitted_by: submitted_by,
      submitter_entity: submitted_by&.entity,
      request_id: request_id,
      # Saving these writes the validated Paperclip files to storage, so the
      # payload never has to carry the attachment data.
      file_uploads: detached_file_uploads,
      status: 'received'
    )
  end

  # The uploads were built by the notice used for validation. That notice is
  # never saved, so they have to let go of it before they can be stored.
  def detached_file_uploads
    file_uploads.to_a.each { |file_upload| file_upload.notice = nil }
  end

  def payload_digest
    @payload_digest ||= Digest::SHA256.hexdigest(JSON.generate(payload))
  end

  def reserve_notice_id
    connection = Notice.connection
    sequence = connection.quote(Notice.sequence_name)
    connection.select_value("SELECT nextval(#{sequence}::regclass)").to_i
  end
end
