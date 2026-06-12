# frozen_string_literal: true

class StripeWebhooksController < ApplicationController
  skip_before_action :authenticate_user_from_token!, :set_profiler_auth, :set_current_user
  skip_after_action :store_action, :include_auth_cookie, :track_usage_with_matomo

  def create
    Enterprise::PaymentProviders::Stripe.handle_webhook(stripe_event)

    head :ok
  rescue Enterprise::PaymentProviders::Stripe::InvalidWebhook => e
    Rails.logger.warn("Rejected Stripe webhook: #{e.class}: #{e.message}")
    head :bad_request
  rescue Enterprise::PaymentProviders::Stripe::ConfigurationError => e
    Rails.logger.error("Stripe webhook is not configured: #{e.message}")
    head :internal_server_error
  end

  private

  def stripe_event
    @stripe_event ||= Enterprise::PaymentProviders::Stripe.construct_event(
      payload: request.body.read,
      signature: request.env['HTTP_STRIPE_SIGNATURE']
    )
  end
end
