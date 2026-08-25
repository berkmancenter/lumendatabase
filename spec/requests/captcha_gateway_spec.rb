require 'rails_helper'

describe 'Captcha gateway', type: :request do
  let(:destination) { CGI.escape('/notices/search?term=example') }

  describe 'GET /captcha_gateway' do
    it 'renders a form that submits the captcha using POST' do
      get captcha_gateway_index_path, params: { destination: destination }

      expect(response).to be_successful
      expect(response.body).to include('method="post"')
      expect(response.body).to include('name="destination"')
    end
  end

  describe 'POST /captcha_gateway' do
    it 'accepts a large successful captcha response without overflowing the session cookie' do
      allow_any_instance_of(CaptchaGatewayController).to receive(:verify_recaptcha).and_return(true)

      expect {
        post captcha_gateway_index_path,
             params: {
               destination: destination,
               'g-recaptcha-response': 'a' * 4_000
             }
      }.not_to raise_error

      expect(response).to redirect_to('/notices/search?term=example')
      expect(session[:captcha_permission]).to be > Time.now
      expect(session.to_hash.to_s).not_to include('a' * 100)
    end

    it 'redirects failed verification without copying the captcha response into the URL' do
      allow_any_instance_of(CaptchaGatewayController).to receive(:verify_recaptcha).and_return(false)

      post captcha_gateway_index_path,
           params: {
             destination: destination,
             'g-recaptcha-response': 'secret-captcha-response'
           }

      expect(response).to redirect_to(
        captcha_gateway_index_path(destination: destination)
      )
      expect(response.location).not_to include('secret-captcha-response')
    end
  end
end
