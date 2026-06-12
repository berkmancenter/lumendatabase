# frozen_string_literal: true

require 'stripe'

Stripe.api_key = ENV['STRIPE_SECRET_KEY'] if ENV['STRIPE_SECRET_KEY'].present?
Stripe.api_version = ENV['STRIPE_API_VERSION'] if ENV['STRIPE_API_VERSION'].present?
