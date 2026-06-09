# frozen_string_literal: true

module RedisCacheStoreConfig
  def self.enabled?
    ENV['RAILS_CACHE_REDIS_URL'].to_s.strip != ''
  end

  def self.options
    {
      url: ENV.fetch('RAILS_CACHE_REDIS_URL'),
      namespace: ENV.fetch('RAILS_CACHE_NAMESPACE', "lumen-#{Rails.env}"),
      pool: {
        size: ENV.fetch(
          'RAILS_CACHE_POOL_SIZE',
          ENV.fetch('DATABASE_POOL', ENV.fetch('RAILS_MAX_THREADS', 5))
        ).to_i,
        timeout: ENV.fetch('RAILS_CACHE_POOL_TIMEOUT', 5).to_i
      }
    }
  end
end
