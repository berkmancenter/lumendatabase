# frozen_string_literal: true

module Enterprise::PaymentMethods
  class Error < StandardError; end
  class UnsupportedPaymentMethod < Error; end

  Result = Struct.new(
    :redirect_to,
    :notice,
    :alert,
    :status,
    :allow_other_host,
    keyword_init: true
  ) do
    def redirect_options
      {
        notice: notice,
        alert: alert,
        status: status,
        allow_other_host: allow_other_host
      }.compact
    end
  end

  REGISTRY = {
    'credit_card' => {
      label: 'Credit card',
      class_name: 'Enterprise::PaymentMethods::CreditCard'
    },
    'invoice' => {
      label: 'Invoice',
      class_name: 'Enterprise::PaymentMethods::Invoice'
    }
  }.freeze

  def self.names
    REGISTRY.keys
  end

  def self.options
    REGISTRY.map { |value, config| [config.fetch(:label), value] }
  end

  def self.for(payment_method, **context)
    config = REGISTRY[payment_method.to_s]
    raise UnsupportedPaymentMethod, 'Please choose a payment method.' unless config

    config.fetch(:class_name).constantize.new(**context)
  end

  def self.for_payment(payment, **context)
    self.for(payment.payment_method, **context)
  end
end
