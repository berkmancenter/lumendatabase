# frozen_string_literal: true

module LumenJobQueues
  DEFAULT_QUEUE = 'default'

  class << self
    def active_job_queue_prefix(env = ENV)
      env_value(env, 'ACTIVE_JOB_QUEUE_PREFIX') || env_value(env, 'LUMEN_INSTANCE_POOL')
    end

    def sidekiq_queue(env = ENV)
      env_value(env, 'SIDEKIQ_QUEUE') || queue_name(DEFAULT_QUEUE, env)
    end

    def queue_name(queue, env = ENV)
      queue = string_value(queue) || DEFAULT_QUEUE
      queue_prefix = active_job_queue_prefix(env)

      queue_prefix ? "#{queue_prefix}_#{queue}" : queue
    end

    private

    def env_value(env, key)
      string_value(env[key])
    end

    def string_value(value)
      value = value.to_s.strip
      value unless value.empty?
    end
  end
end
