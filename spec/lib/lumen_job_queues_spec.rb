require 'rails_helper'

RSpec.describe LumenJobQueues do
  describe '.active_job_queue_prefix' do
    it 'uses an explicit Active Job queue prefix first' do
      env = {
        'ACTIVE_JOB_QUEUE_PREFIX' => 'custom',
        'LUMEN_INSTANCE_POOL' => 'notices'
      }

      expect(described_class.active_job_queue_prefix(env)).to eq('custom')
    end

    it 'falls back to the Lumen instance pool' do
      env = {
        'ACTIVE_JOB_QUEUE_PREFIX' => '',
        'LUMEN_INSTANCE_POOL' => 'notices'
      }

      expect(described_class.active_job_queue_prefix(env)).to eq('notices')
    end

    it 'returns nil when no queue prefix is configured' do
      expect(described_class.active_job_queue_prefix({})).to be_nil
    end
  end

  describe '.queue_name' do
    it 'adds the resolved prefix to a queue name' do
      env = { 'LUMEN_INSTANCE_POOL' => 'admin' }

      expect(described_class.queue_name('default', env)).to eq('admin_default')
    end

    it 'uses the bare queue name without a prefix' do
      expect(described_class.queue_name('default', {})).to eq('default')
    end
  end

  describe '.sidekiq_queue' do
    it 'uses an explicit Sidekiq queue first' do
      env = {
        'SIDEKIQ_QUEUE' => 'critical',
        'LUMEN_INSTANCE_POOL' => 'search'
      }

      expect(described_class.sidekiq_queue(env)).to eq('critical')
    end

    it 'falls back to the resolved default queue' do
      env = { 'LUMEN_INSTANCE_POOL' => 'search' }

      expect(described_class.sidekiq_queue(env)).to eq('search_default')
    end
  end
end
