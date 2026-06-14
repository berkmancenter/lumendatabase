class EnterpriseAccount < ApplicationRecord
  PLANS = %w[inactive pro].freeze

  # Review lifecycle, independent of plan (which tracks paid access):
  #   pre_registration -> approved | rejected
  # A registration starts in pre_registration with no user; an admin accepts
  # (creating the user) or rejects it.
  STATUSES = %w[pre_registration approved rejected].freeze

  PAYMENT_METHODS = Lumen::Enterprise::PaymentMethods.names.freeze
  PAYMENT_METHOD_OPTIONS = Lumen::Enterprise::PaymentMethods.options.freeze

  PRO_PERIOD = 1.month

  # How many days before paid_until to email invoice-billed accounts a renewal
  # invoice: one week and one day before the Pro period ends.
  RENEWAL_REMINDER_DAYS = [7, 1].freeze

  REPORT_FREQUENCIES = %w[none daily weekly].freeze
  REPORT_FREQUENCY_OPTIONS = [
    ['Off', 'none'],
    ['Daily', 'daily'],
    ['Weekly', 'weekly']
  ].freeze

  # Detach users when the account is deleted (they may keep other roles/logins)
  # rather than blocking the delete on the users foreign key.
  has_many :users, dependent: :nullify
  has_many :enterprise_domains, dependent: :destroy
  has_many :enterprise_payments, dependent: :restrict_with_error

  accepts_nested_attributes_for :enterprise_domains, allow_destroy: true

  validates :name, presence: true
  validates :report_frequency, inclusion: { in: REPORT_FREQUENCIES }
  validates :plan, presence: true, inclusion: { in: PLANS }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }, allow_blank: true
  validates :applicant_email, presence: true, if: :pre_registration?

  scope :pro, -> { where(plan: 'pro') }
  scope :reporting_enabled, -> { pro.where.not(report_frequency: 'none') }
  scope :renewal_invoice_candidates, lambda {
    pro.where(payment_method: 'invoice').where.not(paid_until: nil)
  }

  def pro?
    plan == 'pro'
  end

  def pre_registration?
    status == 'pre_registration'
  end

  def approved?
    status == 'approved'
  end

  def rejected?
    status == 'rejected'
  end

  # Admin accepts the registration: mark it approved, create (or attach) the
  # enterprise user with an unconfirmed email + confirmation token, and email
  # them the confirm-email/set-password link. Mirrors
  # ApiSubmitterRequest#approve_request. Returns the user.
  def approve_registration!
    ensure_applicant_email_present!

    user = nil

    transaction do
      update!(status: 'approved')
      user = build_applicant_user
    end

    Enterprise::RegistrationMailer.email_confirmation(self, user).deliver_later

    user
  end

  # Admin rejects the registration: mark it rejected and let the applicant know.
  def reject_registration!
    ensure_applicant_email_present!

    update!(status: 'rejected')

    Enterprise::RegistrationMailer.client_rejected(self).deliver_later
  end

  def payment_method_label
    PAYMENT_METHOD_OPTIONS
      .find { |_label, value| value == payment_method }
      &.first || payment_method
  end

  def pending_credit_card_payment
    pending_payment(payment_method: 'credit_card')
  end

  def pending_payment(payment_method: nil)
    payments = enterprise_payments.pending
    payments = payments.where(payment_method: payment_method) if payment_method.present?

    payments.order(created_at: :desc).first
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

  # True when an invoice-billed Pro account is exactly one week or one day from
  # the end of its paid period and hasn't already been reminded today (so the
  # daily task is safe to run more than once a day).
  def renewal_reminder_due?(now = Time.current)
    return false unless pro? && payment_method == 'invoice'
    return false if paid_until.blank?
    return false unless RENEWAL_REMINDER_DAYS.include?(days_until_paid_until(now))
    return true if last_renewal_reminder_sent_at.blank?

    last_renewal_reminder_sent_at.to_date < now.to_date
  end

  private

  # Find an existing user for the applicant email or create one with a throwaway
  # password (they set their real password during email confirmation). Either
  # way the user is left unconfirmed with a fresh confirmation token and tied to
  # this account with the enterprise role.
  def build_applicant_user
    user = User.find_by(email: applicant_email) ||
           User.new(email: applicant_email, password: SecureRandom.hex(16))

    user.enterprise_account = self
    user.roles = (user.roles | [Role.enterprise])
    user.enterprise_email_confirmed_at = nil
    user.assign_enterprise_email_confirmation_token
    user.save!

    user
  end

  def ensure_applicant_email_present!
    return if applicant_email.present?

    errors.add(:applicant_email, :blank) unless errors.added?(:applicant_email, :blank)
    raise ActiveRecord::RecordInvalid, self
  end

  def days_until_paid_until(now)
    (paid_until.to_date - now.to_date).to_i
  end

  def report_interval(now)
    case report_frequency
    when 'weekly'
      now - 1.week
    else
      now - 1.day
    end
  end
end
