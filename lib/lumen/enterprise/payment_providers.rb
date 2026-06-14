# frozen_string_literal: true

module Lumen::Enterprise::PaymentProviders
  class Error < StandardError; end
  class UnsupportedProvider < Error; end

  REGISTRY = {
    'stripe' => 'Lumen::Enterprise::PaymentProviders::Stripe'
  }.freeze

  def self.names
    REGISTRY.keys
  end

  def self.fetch(provider)
    class_name = REGISTRY[provider.to_s]
    raise UnsupportedProvider, "Unsupported payment provider: #{provider}" unless class_name

    class_name.constantize
  end
end
