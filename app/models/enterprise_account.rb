class EnterpriseAccount < ApplicationRecord
  REPORT_FREQUENCIES = %w[none daily weekly].freeze

  has_many :users
  has_many :enterprise_domains, dependent: :destroy

  accepts_nested_attributes_for :enterprise_domains, allow_destroy: true

  validates :name, presence: true
  validates :report_frequency, inclusion: { in: REPORT_FREQUENCIES }

  scope :active, -> { where(active: true) }
  scope :reporting_enabled, -> { active.where.not(report_frequency: 'none') }

  def verified_domains
    enterprise_domains.verified
  end

  def verified_domain_names
    verified_domains.pluck(:domain)
  end

  def report_recipient
    report_recipient_email.presence || users.order(:id).first&.email
  end

  def report_due?(now = Time.current)
    return false unless active?
    return false if report_frequency == 'none'
    return false if report_recipient.blank?
    return true if last_report_sent_at.blank?

    last_report_sent_at <= report_interval(now)
  end

  def report_period_start(now = Time.current)
    last_report_sent_at || report_interval(now)
  end

  private

  def report_interval(now)
    case report_frequency
    when 'weekly'
      now - 1.week
    else
      now - 1.day
    end
  end
end
