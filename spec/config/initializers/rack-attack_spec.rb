require 'spec_helper'

describe Rack::Attack do
  include Rack::Test::Methods
  let(:notice) { create(:dmca) }

  def app
    Rails.application
  end

  describe 'throttling excessive API requests by IP address', cache: true do
    let(:limit) { 5 }

    context 'number of requests is lower than the limit' do
      it 'allows requests' do
        limit.times do |i|
          get '/topics.json', {}, 'REMOTE_ADDR' => '1.2.3.4'
          expect(last_response.status).to eq(200) if i == limit
        end
      end
    end

    context 'number of requests is higher than the limit', cache: true do
      it 'blocks requests' do
        (limit + 1).times do |i|
          get '/topics.json', {}, 'REMOTE_ADDR' => '1.2.3.5'
          expect(last_response.status).to eq(429) if i > limit
        end
      end
    end
  end

  describe 'throttling excessive HTTP responses by IP address' do
    let(:limit) { 10 }

    context 'number of requests is lower than the limit', cache: true do
      it 'allows requests' do
        limit.times do |i|
          get "/notices/#{notice.id}", {}, 'REMOTE_ADDR' => '1.2.3.9'
          expect(last_response.status).to eq(200) if i == limit
        end
      end
    end

    context 'number of requests is higher than the limit', cache: true do
      it 'blocks requests' do
        (limit + 1).times do |i|
          get "/notices/#{notice.id}", {}, 'REMOTE_ADDR' => '1.2.4.7'
          expect(last_response.status).to eq(200) if i > limit
        end
      end
    end

    context 'when user is logged in' do
      it 'lets researchers have access' do
        u = create(:user, :researcher)
        sign_in u
        (limit + 1).times do |i|
          get "/notices/#{notice.id}", {}, 'REMOTE_ADDR' => '1.2.3.10'
          expect(last_response.status).to eq(200) if i > limit
        end
      end

      it 'lets admins have access' do
        u = create(:user, :admin)
        sign_in u
        (limit + 1).times do |i|
          get "/notices/#{notice.id}", {}, 'REMOTE_ADDR' => '1.2.3.11'
          expect(last_response.status).to eq(200) if i > limit
        end
      end

      it 'lets super_admins have access' do
        u = create(:user, :super_admin)
        sign_in u
        (limit + 1).times do |i|
          get "/notices/#{notice.id}", {}, 'REMOTE_ADDR' => '1.2.3.12'
          expect(last_response.status).to eq(200) if i > limit
        end
      end

      it 'does not let non-permissioned users have access' do
        u = create(:user)
        sign_in u
        (limit + 1).times do |i|
          get "/notices/#{notice.id}", {}, 'REMOTE_ADDR' => '1.2.3.13'
          expect(last_response.status).to eq(429) if i > limit
        end
      end
    end
  end
end
