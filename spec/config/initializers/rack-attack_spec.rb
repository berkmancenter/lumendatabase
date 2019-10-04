require 'rails_helper'

describe Rack::Attack, type: :request do
  # Online you'll find suggestions to include Rack::Test::Methods here and use
  # last_response in testing rack-attack. I'm not doing so as I have found
  # last_response.status to be unreliable; it doesn't yield identical values
  # with invocations that I would expect to point to identical objects.
  # I think the challenge is that the throttles are defined on app load, which
  # means that instances of Rack::Attack::Throttle already exist, and have
  # :limit attributes, so overwriting limit in the tests has no effect;
  # you have to directly stub out the calls to the throttles, which we do below.
  let(:notice) { create(:dmca) }
  let(:statuses) { [] }
  let(:limit) { 1 }

  # Rack::Attack defines its own cache, so it isn't controlled by the
  # cache: true option in spec_helper. Also its cache doesn't have a `clear`
  # method, so tests pollute one another. Let's just blow away and reinitialize
  # the cache store between tests.
  before(:each) do
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  describe 'get requests by authenticated users' do
    context 'number of requests is lower than the limit' do
      it 'allows requests to /notice' do
        stub_authentication

        limit.times do |i|
          get "/notices/#{notice.id}"
          statuses << response.status
        end
        expect(statuses).to eq([200])
      end

      it 'allows requests to .json' do
        stub_authentication

        limit.times do |i|
          get '/topics.json'
          statuses << response.status
        end
        expect(statuses).to eq([200])
      end

      it 'allows requests to faceted_search', search: true do
        stub_authentication

        limit.times do |i|
          get '/faceted_search?term=batman'
          statuses << response.status
        end
        expect(statuses).to eq([200])
      end
    end

    context 'number of requests is higher than the limit' do
      it 'blocks requests to notices' do
        stub_authentication

        (limit + 1).times do |i|
          get "/notices/#{notice.id}"
          statuses << response.status
        end
        expect(statuses).to eq([200, 429])
      end

      it 'blocks requests to .json' do
        stub_authentication

        (limit + 1).times do |i|
          get '/topics.json'
          statuses << response.status
        end
        expect(statuses).to eq([200, 429])
      end
    end

    it 'blocks requests to faceted_search', search: true do
      stub_authentication

      (limit + 1).times do |i|
        get '/faceted_search?term=batman'
        statuses << response.status
      end
      expect(statuses).to eq([200, 429])
    end
  end

  describe 'get requests by unauthenticated users' do
    context 'number of requests is lower than the limit' do
      it 'allows requests to /notices' do
        stub_nonauthentication

        limit.times do |i|
          get "/notices/#{notice.id}"
          statuses << response.status
        end
        expect(statuses).to eq([200])
      end

      it 'allows requests to .json' do
        stub_nonauthentication

        limit.times do |i|
          get '/topics.json'
          statuses << response.status
        end
        expect(statuses).to eq([200])
      end

      it 'allows requests to faceted_search', search: true do
        stub_authentication

        limit.times do |i|
          get '/faceted_search?term=batman'
          statuses << response.status
        end
        expect(statuses).to eq([200])
      end
    end

    context 'number of requests is higher than the limit' do
      it 'blocks requests to /notices' do
        stub_nonauthentication

        (limit + 1).times do |i|
          get "/notices/#{notice.id}"
          statuses << response.status
        end
        expect(statuses).to eq([200, 429])
      end

      it 'blocks requests to .json' do
        stub_nonauthentication

        (limit + 1).times do |i|
          get '/topics.json'
          statuses << response.status
        end
        expect(statuses).to eq([200, 429])
      end
    end

    it 'blocks requests to faceted_search', search: true do
      stub_authentication

      (limit + 1).times do |i|
        get '/faceted_search?term=batman'
        statuses << response.status
      end
      expect(statuses).to eq([200, 429])
    end
  end

  def isolate
    allow_any_instance_of(Rack::Attack::Throttle).to receive(:limit).and_return(limit)
    allow_any_instance_of(Rack::Attack::Request).to receive(:localhost?).and_return(false)
    allow_any_instance_of(Rack::Attack::Request).to receive(:ip).and_return("1.2.3.#{line}")
  end

  def stub_authentication
    isolate
    allow_any_instance_of(Rack::Attack::Request).to receive(:authenticated?).and_return(true)
    allow_any_instance_of(Rack::Attack::Request).to receive(:discriminator).and_return('yo')
  end

  def stub_nonauthentication
    isolate
    allow_any_instance_of(Rack::Attack::Request).to receive(:authenticated?).and_return(false)
  end

  # This finds the line number of the example in this file which ultimately
  # called this function. This allows for each example to have a distinct IP
  # address, so that they don't interfere with one another by writing the same
  # cache key.
  # Today I learned that caller_locations exists and provides a fun stacktrace.
  def line
    caller_locations.select { |loc| loc.path.include? 'rack-attack_spec' }
                    .reject { |loc| loc.label.include? 'stub_' }
                    .first
                    .lineno
  end
end
