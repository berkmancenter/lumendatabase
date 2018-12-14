require 'spec_helper'

describe NoticesHelper do
  include NoticesHelper

  context '#can_see_full_notice_version?' do
    let(:notice) { create(:dmca) }
    let(:token_url) do
      create(
        :token_url,
        email: 'user@example.com',
        notice: notice
      )
    end

    it 'returns true when the user is allowed to see the full notice version' do
      allow_any_instance_of(NoticesHelper).to receive(:params).and_return({access_token: token_url.token})
      allow_any_instance_of(NoticesHelper).to receive(:can?).and_return(true)

      result = can_see_full_notice_version?(notice)

      expect(result).to eq(true)
    end

    it 'returns true when the user is not allowed to see the full notice version and the token is valid' do
      allow_any_instance_of(NoticesHelper).to receive(:params).and_return({access_token: token_url.token})
      allow_any_instance_of(NoticesHelper).to receive(:can?).and_return(false)

      result = can_see_full_notice_version?(notice)

      expect(result).to eq(true)
    end

    it 'returns false when the token is not valid and the user not allowed to see the full notice version' do
      allow_any_instance_of(NoticesHelper).to receive(:params).and_return({access_token: 'WHATEVER'})
      allow_any_instance_of(NoticesHelper).to receive(:can?).and_return(false)

      result = can_see_full_notice_version?(notice)

      expect(result).to eq(false)
    end
  end

  context 'permanent_url_full_notice' do
    let(:notice) { create(:dmca) }
    let(:user) { create(:user) }

    it 'returns false when no token url is found' do
      allow_any_instance_of(NoticesHelper).to receive(:current_user).and_return(user)

      result = permanent_url_full_notice(notice)

      expect(result).to eq(false)
    end

    it 'returns a proper url when a token url is found' do
      token_url = create(
        :token_url,
        email: 'user@example.com',
        notice: notice,
        user: user,
        valid_forever: true
      )

      allow_any_instance_of(NoticesHelper).to receive(:current_user).and_return(user)

      result = permanent_url_full_notice(notice)

      expect(result).to eq(notice_url(
                             notice,
                             access_token: token_url.token,
                             host: Chill::Application.config.site_host
                           ))
    end
  end
end
