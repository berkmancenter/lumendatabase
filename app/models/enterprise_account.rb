class EnterpriseAccount < ApplicationRecord
  PLANS = %w[inactive pro].freeze

  PAYMENT_METHODS = %w[credit_card invoice].freeze
  PAYMENT_METHOD_OPTIONS = [
    ['Credit card', 'credit_card'],
    ['Invoice', 'invoice']
  ].freeze

  PRO_PERIOD = 1.month

  REPORT_FREQUENCIES = %w[none daily weekly].freeze
  REPORT_FREQUENCY_OPTIONS = [
    ['Off', 'none'],
    ['Daily', 'daily'],
    ['Weekly', 'weekly']
  ].freeze

  has_many :users
  has_many :enterprise_domains, dependent: :destroy

  accepts_nested_attributes_for :enterprise_domains, allow_destroy: true

  validates :name, presence: true
  validates :report_frequency, inclusion: { in: REPORT_FREQUENCIES }
  validates :plan, presence: true, inclusion: { in: PLANS }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }, allow_blank: true

  scope :pro, -> { where(plan: 'pro') }
  scope :reporting_enabled, -> { pro.where.not(report_frequency: 'none') }

  def pro?
    plan == 'pro'
  end

  def payment_method_label
    PAYMENT_METHOD_OPTIONS
      .find { |_label, value| value == payment_method }
      &.first || payment_method
  end

  # Promote the account to Pro and (re)set how long that access lasts. Extends an
  # existing paid period when one is still in the future so consecutive payments
  # accumulate rather than overwrite. Does not persist; the caller saves.
  def extend_pro_access!(from: Time.current, duration: PRO_PERIOD)
    self.plan = 'pro'
    base = [paid_until, from].compact.max
    self.paid_until = base + duration
  end

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
    return false unless pro?
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
