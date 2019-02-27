require 'spec_helper'

describe NoticesHelper do
  include NoticesHelper

  context 'permanent_url_full_notice' do
    let(:notice) { create(:dmca) }
    let(:user) { create(:user) }

    it 'returns false when no token url is found' do
      allow_any_instance_of(NoticesHelper).to receive(:current_user).and_return(user)

      result = permanent_url_full_notice(notice)

      expect(result).to eq(false)
    end

    it 'returns a proper url when a token url is found' do
      token_url = create_token_url

      allow_any_instance_of(NoticesHelper).to receive(:current_user).and_return(user)

      result = permanent_url_full_notice(notice)

      expect(result).to eq(notice_url(
                             notice,
                             access_token: token_url.token,
                             host: Chill::Application.config.site_host
                           ))
    end

    it 'returns false when current_user is nil' do
      create_token_url

      allow_any_instance_of(NoticesHelper).to receive(:current_user).and_return(nil)

      result = permanent_url_full_notice(notice)

      expect(result).to eq(false)
    end
  end

  private

  def create_token_url
    create(
      :token_url,
      notice: notice,
      user: user,
      valid_forever: true
    )
  end
end
