# frozen_string_literal: true

class Enterprise::PaymentMethods::Base
  def initialize(enterprise_account:, user:, urls:)
    @enterprise_account = enterprise_account
    @user = user
    @urls = urls
  end

  def start
    raise NotImplementedError
  end

  def cancel(payment:)
    raise NotImplementedError
  end

  private

  attr_reader :enterprise_account, :user, :urls

  def payment_method
    self.class::PAYMENT_METHOD
  end

  def pending_payment
    enterprise_account.pending_payment(payment_method: payment_method)
  end

  def redirect_result(...)
    Enterprise::PaymentMethods::Result.new(...)
  end
end
