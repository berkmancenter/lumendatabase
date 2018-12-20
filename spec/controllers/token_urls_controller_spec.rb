require 'rails_helper'

describe TokenUrlsController do
  context '#new' do
    it 'finds the notice when it exists and renders successfully' do
      notice = Notice.new
      expect(Notice).to receive(:find).with('1').and_return(notice)

      get :new, id: 1

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

      post :create, params

      expect(TokenUrl.first.notice).to eq notice
      expect(TokenUrl.first.email).to eq 'user@example.com'
    end

    it 'fails to create a new token url when illegal params are provided' do
      allow(controller).to receive(:verify_recaptcha).and_return(true)

      notice = create(:dmca)

      params = {
        token_url: {
          email: 'user@example.com',
          notice_idX: notice.id
        }
      }

      expect {
        post :create, params
      }.to raise_error(ActionController::UnpermittedParameters)
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

      post :create, params

      expect(TokenUrl.first.email).to eq 'user@example.com'
    end
  end
end
