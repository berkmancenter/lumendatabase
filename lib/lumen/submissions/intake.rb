# frozen_string_literal: true

require 'digest'

class Lumen::Submissions::Intake
  def initialize(notice_type:, payload:, submitted_by:, request_id: nil)
    @notice_type = notice_type
    @payload = payload.deep_stringify_keys
    @submitted_by = submitted_by
    @request_id = request_id
  end

  def call
    create_request
  end

  private

  attr_reader :notice_type, :payload, :request_id, :submitted_by

  def create_request
    NoticeSubmissionRequest.create!(
      reserved_notice_id: reserve_notice_id,
      notice_type: notice_type.name,
      payload: payload,
      payload_digest: payload_digest,
      submitted_by: submitted_by,
      submitter_entity: submitted_by&.entity,
      request_id: request_id,
      status: 'received'
    )
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
