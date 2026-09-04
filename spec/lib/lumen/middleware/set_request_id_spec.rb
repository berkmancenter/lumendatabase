require 'rails_helper'

RSpec.describe Lumen::Middleware::SetRequestId do
  after { Current.reset }

  describe '#call' do
    it 'sets the current request id and URL' do
      app = lambda do |_env|
        expect(Current.request_id).to eq('request-id')
        expect(Current.request_url).to eq('https://www.example.com/notices?page=2')

        [200, {}, []]
      end
      middleware = described_class.new(app)
      env = Rack::MockRequest.env_for('https://www.example.com/notices?page=2')
      env['action_dispatch.request_id'] = 'request-id'

      expect(middleware.call(env)).to eq([200, {}, []])
    end

    it 'filters sensitive parameters from the current request URL' do
      app = lambda do |_env|
        expect(Current.request_url).to eq(
          'https://www.example.com/captcha_gateway?' \
          'destination=%2Fnotices&g-recaptcha-response=[FILTERED]'
        )

        [200, {}, []]
      end
      middleware = described_class.new(app)
      env = Rack::MockRequest.env_for(
        'https://www.example.com/captcha_gateway?' \
        'destination=%2Fnotices&g-recaptcha-response=secret-token'
      )
      env['action_dispatch.parameter_filter'] =
        Rails.application.config.filter_parameters

      expect(middleware.call(env)).to eq([200, {}, []])
    end
  end
end
