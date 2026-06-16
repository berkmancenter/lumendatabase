class EnterpriseReport < ApplicationRecord
  STATUSES = %w[pending ready failed].freeze

  belongs_to :enterprise_account
  belongs_to :requested_by, class_name: 'User', optional: true

  has_one_attached :file

  before_validation :ensure_download_token, on: :create

  validates :download_token, presence: true, uniqueness: true
  validates :ends_at, presence: true
  validates :enterprise_account, presence: true
  validates :requested_by_email, presence: true
  validates :starts_at, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  validate :starts_at_before_ends_at

  scope :ready, -> { where(status: 'ready') }

  def pending?
    status == 'pending'
  end

  def ready?
    status == 'ready'
  end

  def failed?
    status == 'failed'
  end

  def downloadable?
    ready? && file.attached?
  end

  def attach_json!(json)
    file.attach(
      io: StringIO.new(json),
      filename: download_filename,
      content_type: 'application/json'
    )

    update!(
      status: 'ready',
      completed_at: Time.current,
      failed_at: nil,
      failure_message: nil
    )
  end

  def mark_failed!(error)
    update!(
      status: 'failed',
      failed_at: Time.current,
      failure_message: "#{error.class}: #{error.message}".truncate(2_000)
    )
  end

  def download_filename
    [
      'lumen-enterprise-report',
      starts_at.to_date.iso8601,
      ends_at.to_date.iso8601
    ].join('-') + '.json'
  end

  private

  def ensure_download_token
    self.download_token ||= loop do
      token = SecureRandom.urlsafe_base64(32, false)
      break token unless EnterpriseReport.exists?(download_token: token)
    end
  end

  def starts_at_before_ends_at
    return if starts_at.blank? || ends_at.blank?
    return if starts_at < ends_at

    errors.add(:ends_at, 'must be after start date')
  end
end
