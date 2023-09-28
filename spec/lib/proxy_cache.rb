require 'rails_helper'

RSpec.describe ProxyCache do
  describe '.clear_notice' do
    it 'clears cache for a single notice' do
      notice_id = 1

      expect(ClearCacheJob).to receive(:set).with(wait: 0.seconds).and_return(ClearCacheJob)
      expect(ClearCacheJob).to receive(:perform_later).with(notice_url(notice_id))

      ProxyCache.clear_notice(notice_id)
    end

    it 'clears cache for multiple notices' do
      notice_ids = [1, 2, 3]
      i= 0 

      notice_ids.each do |notice_id|
        n_delay = i * ProxyCache::REQUEST_SLEEP_SECONDS
        expect(ClearCacheJob).to receive(:set).with(wait: n_delay.seconds).and_return(ClearCacheJob)
        expect(ClearCacheJob).to receive(:perform_later).with(notice_url(notice_id))

        i += 1
      end

      ProxyCache.clear_notice(notice_ids)
    end

    it 'does not clear cache if CLEAR_HEADER is not set' do
      ENV['PROXY_CACHE_CLEAR_HEADER'] = nil
      ProxyCache.send(:remove_const, 'CLEAR_HEADER')
      ProxyCache.const_set('CLEAR_HEADER', nil)

      expect(ProxyCache).not_to receive(:call)

      ProxyCache.clear_notice(1)
    end
  end

  describe '.call' do
    it 'enqueues a ClearCacheJob with the given URL and delay' do
      id = 1

      expect(ClearCacheJob).to receive(:set).with(wait: 0.seconds).and_return(ClearCacheJob)
      expect(ClearCacheJob).to receive(:perform_later).with(notice_url(id))

      ProxyCache.call(notice_url(1))
    end
  end

  describe '.call_many' do
    it 'enqueues ClearCacheJob for multiple URLs with the specified delay' do
      notice_ids = [1, 2, 3]
      i = 0

      notice_ids.each do |id|
        n_delay = i * ProxyCache::REQUEST_SLEEP_SECONDS
        expect(ClearCacheJob).to receive(:set).with(wait: n_delay.seconds).and_return(ClearCacheJob)
        expect(ClearCacheJob).to receive(:perform_later).with(notice_url(id))

        i += 1
      end

      ProxyCache.call_many(notice_ids)
    end
  end

  describe '.notice_url' do
    it 'generates the correct notice URL' do
      notice_id = 42
      expected_url = "#{SITE_URL}/notices/#{notice_id}"

      generated_url = ProxyCache.notice_url(notice_id)

      expect(generated_url).to eq(expected_url)
    end
  end

  private

  def notice_url(id)
    Rails.application.routes.url_helpers.notice_url(host: ENV['SITE_HOST'], id: id)
  end
end
