class EnterprisePayment < ApplicationRecord
  PROVIDERS = Enterprise::PaymentProviders.names.freeze
  PAYMENT_METHODS = Enterprise::PaymentMethods.names.freeze
  STATUSES = %w[pending completed failed expired canceled].freeze

  belongs_to :enterprise_account
  belongs_to :user, optional: true

  validates :provider, presence: true, inclusion: { in: PROVIDERS }
  validates :payment_method, presence: true, inclusion: { in: PAYMENT_METHODS }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, presence: true
  validates :stripe_checkout_session_id, uniqueness: true, allow_blank: true
  validates :stripe_payment_intent_id, uniqueness: true, allow_blank: true
  validates :stripe_event_id, uniqueness: true, allow_blank: true

  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }

  def completed?
    status == 'completed'
  end

  def pending?
    status == 'pending'
  end
end
