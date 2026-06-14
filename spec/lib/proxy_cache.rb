require 'rails_helper'

RSpec.describe Lumen::Cache::Proxy do
  describe '.clear_notice' do
    it 'clears cache for a single notice' do
      notice_id = 1

      expect(ClearCacheJob).to receive(:set).with(wait: 0.seconds).and_return(ClearCacheJob)
      expect(ClearCacheJob).to receive(:perform_later).with(notice_url(notice_id))

      Lumen::Cache::Proxy.clear_notice(notice_id)
    end

    it 'clears cache for multiple notices' do
      notice_ids = [1, 2, 3]
      i= 0 

      notice_ids.each do |notice_id|
        n_delay = i * Lumen::Cache::Proxy::REQUEST_SLEEP_SECONDS
        expect(ClearCacheJob).to receive(:set).with(wait: n_delay.seconds).and_return(ClearCacheJob)
        expect(ClearCacheJob).to receive(:perform_later).with(notice_url(notice_id))

        i += 1
      end

      Lumen::Cache::Proxy.clear_notice(notice_ids)
    end

    it 'does not clear cache if CLEAR_HEADER is not set' do
      stub_const('Lumen::Cache::Proxy::CLEAR_HEADER', nil)

      expect(Lumen::Cache::Proxy).not_to receive(:call)

      Lumen::Cache::Proxy.clear_notice(1)
    end
  end

  describe '.call' do
    it 'enqueues a ClearCacheJob with the given URL and delay' do
      id = 1

      expect(ClearCacheJob).to receive(:set).with(wait: 0.seconds).and_return(ClearCacheJob)
      expect(ClearCacheJob).to receive(:perform_later).with(notice_url(id))

      Lumen::Cache::Proxy.call(notice_url(1))
    end
  end

  describe '.call_many' do
    it 'enqueues ClearCacheJob for multiple URLs with the specified delay' do
      notice_ids = [1, 2, 3]
      i = 0

      notice_ids.each do |id|
        n_delay = i * Lumen::Cache::Proxy::REQUEST_SLEEP_SECONDS
        expect(ClearCacheJob).to receive(:set).with(wait: n_delay.seconds).and_return(ClearCacheJob)
        expect(ClearCacheJob).to receive(:perform_later).with(notice_url(id))

        i += 1
      end

      Lumen::Cache::Proxy.call_many(notice_ids)
    end
  end

  describe '.notice_url' do
    it 'generates the correct notice URL' do
      notice_id = 42
      expected_url = notice_url(notice_id)

      generated_url = Lumen::Cache::Proxy.notice_url(notice_id)

      expect(generated_url).to eq(expected_url)
    end
  end

  private

  def notice_url(id)
    Rails.application.routes.url_helpers.notice_url(
      host: ENV['PROXY_CACHE_CLEAR_SITE_HOST'],
      id: id
    )
  end
end
