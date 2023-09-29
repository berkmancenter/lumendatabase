Sidekiq.configure_server do |config|
  config.redis = { url: ENV['SIDEKIQ_REDIS_URL'] || 'redis://localhost:6379/1' }
end
Sidekiq.configure_client do |config|
  config.redis = { url: ENV['SIDEKIQ_REDIS_URL'] || 'redis://localhost:6379/1' }
end

Rails.application.config.active_job.queue_adapter = :sidekiq

# nil will use the "default" queue
# https://github.com/sidekiq/sidekiq/wiki/Active-Job#queues
Rails.application.config.action_mailer.deliver_later_queue_name = nil
Rails.application.config.action_mailbox.queues.routing = nil
Rails.application.config.active_storage.queues.analysis = nil
Rails.application.config.active_storage.queues.purge = nil
Rails.application.config.active_storage.queues.mirror = nil
