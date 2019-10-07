require 'rails_helper'

describe TokenUrlsController do
  context '#new' do
    it 'finds the notice when it exists and renders successfully' do
      notice = Notice.new
      expect(Notice).to receive(:find).with('1').and_return(notice)

      get :new, params: { id: 1 }

      expect(response).to be_successful
      expect(assigns(:notice)).to eq notice
      expect(assigns(:token_url)).to be_an_instance_of TokenUrl
    end
  end

  context '#create' do
    it 'creates a new token url when valid params are provided' do
      allow(controller).to receive(:verify_recaptcha).and_return(true)

      notice = create(:dmca)

      params = {
        token_url: {
          email: 'user@example.com',
          notice_id: notice.id
        }
      }

      post :create, params: params

      expect(TokenUrl.last.notice).to eq notice
      expect(TokenUrl.last.email).to eq 'user@example.com'
    end

    it 'fails to create a new token url when illegal params are provided' do
      allow(controller).to receive(:verify_recaptcha).and_return(true)

      orig_count = TokenUrl.count

      notice = create(:dmca)

      params = {
        token_url: {
          email: 'user@example.com',
          notice_idX: notice.id
        }
      }

      expect {
        post :create, params: params
      }.to raise_error(ActionController::UrlGenerationError)
      expect(TokenUrl.count).to eq orig_count
    end

    it 'creates a new token and strips out the email part between "+" and "@"' do
      allow(controller).to receive(:verify_recaptcha).and_return(true)

      notice = create(:dmca)

      params = {
        token_url: {
          email: 'user+123456@example.com',
          notice_id: notice.id
        }
      }

      post :create, params: params

      expect(TokenUrl.last.email).to eq 'user@example.com'
    end

    it 'disables a documents notification' do
      notice = create(:dmca)
      token_url = create(:token_url, notice: notice, documents_notification: true)

      params = {
        id: token_url.id,
        token: token_url.token
      }

      get :disable_documents_notification, params: params

      expect(TokenUrl.last.documents_notification).to eq(false)
    end

    it "won't disable a documents notification with a wrong token" do
      notice = create(:dmca)
      token_url = create(:token_url, notice: notice, documents_notification: true)

      params = {
        id: token_url.id,
        token: 'hohoho'
      }

      get :disable_documents_notification, params: params

      expect(TokenUrl.last.documents_notification).to eq(true)
    end

    it "won't call the validate method twice" do
      allow(controller).to receive(:verify_recaptcha).and_return(true)
      allow(controller).to receive(:validate).and_return(
        status: false,
        why: 'Captcha verification failed, please try again.'
      )
      expect(controller).to receive(:validate).once

      notice = create(:dmca)

      params = {
        token_url: {
          email: 'user@example.com',
          notice_id: notice.id
        }
      }

      post :create, params: params
    end
  end
end
