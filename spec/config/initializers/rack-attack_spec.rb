require 'spec_helper'

describe Rack::Attack do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  describe 'throttle excessive API requests by IP address', cache: true do
    let(:limit) { 5 }

    context 'number of requests is lower than the limit' do
      it 'does not change the request status' do
        limit.times do
          get '/topics.json', {}, 'REMOTE_ADDR' => '1.2.3.4'
          expect(last_response.status).to_not eq(429)
        end
      end
    end

    context 'number of requests is higher than the limit', cache: true do
      it 'changes the request status to 429' do
        (limit * 2).times do |i|
          get '/topics.json', {}, 'REMOTE_ADDR' => '1.2.3.5'
          expect(last_response.status).to eq(429) if i > limit
        end
      end
    end
  end

  describe 'throttle excessive HTTP responses by IP address' do
    let(:limit) { 200 }

    context 'number of requests is lower than the limit', cache: true do
      it 'does not change the request status' do
        limit.times do
          get '/pages/license', {}, 'REMOTE_ADDR' => '1.2.3.9'
          expect(last_response.status).to_not eq(429)
        end
      end
    end

    context 'number of requests is higher than the limit', cache: true do
      it 'changes the request status to 429' do
        (limit + 1).times do |i|
          get '/pages/license', {}, 'REMOTE_ADDR' => '1.2.4.7'
          expect(last_response.status).to eq(429) if i > limit
        end
      end
    end
  end
end
