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

    it 'returns an error for an anonymous user on a notice with a submitter with full_notice_only_researchers true' do
      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.submitter.full_notice_only_researchers = true
      expect(Notice).to receive(:find).with('1').and_return(notice)

      get :new, params: { id: 1 }

      expect_authorization_error
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
      expect(TokenUrl.last.email).to eq Hasher.hash512('user@example.com')
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

    it 'returns an error for an anonymous user on a notice with a submitter with full_notice_only_researchers true' do
      allow(controller).to receive(:verify_recaptcha).and_return(true)

      orig_count = TokenUrl.count

      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.submitter.full_notice_only_researchers = true
      notice.submitter.save!

      params = {
        token_url: {
          email: 'user@example.com',
          notice_id: notice.id
        }
      }

      post :create, params: params

      expect_authorization_error
      expect(TokenUrl.count).to eq orig_count
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

    it "won't let to request a new token from the same ip immediately" do
      allow(controller).to receive(:verify_recaptcha).and_return(true)

      orig_count = TokenUrl.count

      create_token 'user@example.com'
      create_token 'user2@example.com'

      expect(TokenUrl.count).to eq(orig_count + 1)
    end
  end

  context '#generate_permanent' do
    it 'user with can_generate_permanent_notice_token_urls can generate a permanent token url' do
      user = create(:user, :researcher, can_generate_permanent_notice_token_urls: true)
      allow(controller).to receive(:current_user).and_return(user)

      notice = create(:dmca)

      params = {
        id: notice.id
      }

      post :generate_permanent, params: params

      expect(TokenUrl.where(notice: notice, user: user, valid_forever: true).count).to eq(1)
    end

    it 'user without can_generate_permanent_notice_token_urls can\'t generate a permanent token url' do
      user = create(:user, :researcher)
      allow(controller).to receive(:current_user).and_return(user)

      notice = create(:dmca)

      params = {
        id: notice.id
      }

      post :generate_permanent, params: params

      expect(TokenUrl.where(notice: notice, user: user, valid_forever: true).count).to eq(0)
      expect_authorization_error
    end

    it 'user with can_generate_permanent_notice_token_urls and allow_generate_permanent_tokens_researchers_only_notices access can generate a permanent token url for a sensitive notice' do
      user = create(
        :user,
        :researcher,
        can_generate_permanent_notice_token_urls: true,
        allow_generate_permanent_tokens_researchers_only_notices: true
      )
      allow(controller).to receive(:current_user).and_return(user)

      # Sensitive notice
      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.submitter.full_notice_only_researchers = true
      notice.submitter.save!

      params = {
        id: notice.id
      }

      post :generate_permanent, params: params

      expect(TokenUrl.where(notice: notice, user: user, valid_forever: true).count).to eq(1)
    end

    it 'user with can_generate_permanent_notice_token_urls and without allow_generate_permanent_tokens_researchers_only_notices access can\'t generate a permanent token url for a sensitive notice' do
      user = create(
        :user,
        :researcher,
        can_generate_permanent_notice_token_urls: true,
        allow_generate_permanent_tokens_researchers_only_notices: false
      )
      allow(controller).to receive(:current_user).and_return(user)

      # Sensitive notice
      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.submitter.full_notice_only_researchers = true
      notice.submitter.save!

      params = {
        id: notice.id
      }

      post :generate_permanent, params: params

      expect(TokenUrl.where(notice: notice, user: user, valid_forever: true).count).to eq(0)
      expect_authorization_error
    end

    context '#clean_up_email_address' do
      it 'downcases a new token email address' do
        create_token 'uSer@eXample.com'

        expect(TokenUrl.last.email).to eq Hasher.hash512('user@example.com')
      end

      it 'removes everything between "+" and "@"' do
        create_token 'user+notthistime@example.com'

        expect(TokenUrl.last.email).to eq Hasher.hash512('user@example.com')
      end

      it 'removes periods if a new token email address is gmail' do
        create_token 'user.x.x.x@gmail.com'

        expect(TokenUrl.last.email).to eq Hasher.hash512('userxxx@gmail.com')

        create_token 'user.x.x.x@googlemail.com', '2.2.2.2'

        expect(TokenUrl.last.email).to eq Hasher.hash512('userxxx@googlemail.com')
      end
    end
  end

  private

  def expect_authorization_error
    expect(session['flash']['flashes']['alert']).to eq 'You are not authorized to access this page.'
    expect(response.status).to eq 302
  end

  def create_token(email, ip = '1.1.1.1')
    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip) { ip }
    allow(controller).to receive(:verify_recaptcha).and_return(true)

    notice = create(:dmca)

    params = {
      token_url: {
        email: email,
        notice_id: notice.id
      }
    }

    post :create, params: params
  end
end
