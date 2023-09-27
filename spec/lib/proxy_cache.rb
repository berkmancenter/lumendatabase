require 'rails_helper'

RSpec.describe ProxyCache do
  before do
    ENV['PROXY_CACHE_CLEAR_HEADER'] = 'LUMEN_CLEAR_PROXY_CACHE'
    ProxyCache.send(:remove_const, 'CLEAR_HEADER')
    ProxyCache.const_set('CLEAR_HEADER', 'LUMEN_CLEAR_PROXY_CACHE')
  end

  describe '.clear_notice' do
    context 'when CLEAR_HEADER is set' do
      it 'calls call method when notice_ids is not an array' do
        expect(ProxyCache).to receive(:call).with(instance_of(String))
        ProxyCache.clear_notice(123)
      end

      it 'calls call_many method when notice_ids is an array' do
        expect(ProxyCache).to receive(:call_many).with([123, 456])
        ProxyCache.clear_notice([123, 456])
      end
    end

    context 'when CLEAR_HEADER is not set' do
      before do
        ENV['PROXY_CACHE_CLEAR_HEADER'] = nil
        ProxyCache.send(:remove_const, 'CLEAR_HEADER')
        ProxyCache.const_set('CLEAR_HEADER', nil)
      end

      it 'does not call any methods' do
        expect(ProxyCache).not_to receive(:call)
        expect(ProxyCache).not_to receive(:call_many)
        ProxyCache.clear_notice(123)
      end
    end
  end

  describe '.call' do
    it 'sends an HTTP GET request with the given URL and timeout' do
      url = 'https://example.com'
      timeout = 1

      uri = URI(url)
      http = instance_double(Net::HTTP)
      request = instance_double(Net::HTTP::Get)

      allow(Net::HTTP).to receive(:new).with(uri.host, uri.port).and_return(http)
      allow(http).to receive(:use_ssl=).with(true)
      allow(Net::HTTP::Get).to receive(:new).with(uri.request_uri).and_return(request)
  
      expect(request).to receive(:[]=).with('Host', uri.host)
      expect(request).to receive(:[]=).with('LUMEN_CLEAR_PROXY_CACHE', 'yolo')

      expect(http).to receive(:request).with(request).and_return(Net::HTTPSuccess.new(nil, nil, nil))

      ProxyCache.call(url, timeout)

      sleep(2)
    end
  end

  describe '.call_many' do
    it 'calls the call method for each notice_id with increasing sleep time' do
      notice_ids = [123, 456, 789]
      i = 1
      notice_ids.each do |notice_id|
        expected_timeout = i * 5
        expect(ProxyCache).to receive(:call).with(instance_of(String), expected_timeout)
        i += 1
      end
      ProxyCache.call_many(notice_ids)
    end
  end

  describe '.notice_url' do
    it 'generates the correct notice URL' do
      notice_id = 123
      expect(Rails.application.routes.url_helpers).to receive(:notice_url).with(
        host: Chill::Application.config.site_host,
        id: notice_id
      )
      ProxyCache.notice_url(notice_id)
    end
  end
end
