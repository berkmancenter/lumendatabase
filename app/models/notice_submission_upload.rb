# frozen_string_literal: true

class NoticeSubmissionUpload < ApplicationRecord
  belongs_to :notice_submission_request, inverse_of: :uploads

  has_one_attached :file

  validates :byte_size,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :checksum, :content_type, :original_filename, :parameter_key,
            presence: true
  validates :parameter_key,
            uniqueness: { scope: :notice_submission_request_id }
end
