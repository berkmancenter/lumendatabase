require 'spec_helper'

describe TokenUrl, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:notice) }
  it { is_expected.to validate_presence_of :notice }

  let(:notice) { create(:dmca) }
  let(:token_url) do
    create(
      :token_url,
      notice: notice
    )
  end

  context '#generate_token' do
    it 'generates a token on token url creation' do
      expect(token_url.token).not_to be_empty
    end
  end

  context '.valid?' do
    it 'validates successfully when the token exists in the database' do
      result = TokenUrl.valid?(token_url.token, notice)

      expect(result).to eq(true)
    end

    it 'validates unsuccessfully when the token doesn\'t exist in the database' do
      result = TokenUrl.valid?('NOT_A_TOKEN', notice)

      expect(result).to eq(false)
    end

    it 'validates unsuccessfully when the notice given doesn\'t match' do
      notice_2 = create(:dmca)

      result = TokenUrl.valid?(token_url.token, notice_2)

      expect(result).to eq(false)
    end

    it 'validates unsuccessfully when the token has expired' do
      token_url = create(
        :token_url,
        notice: notice,
        expiration_date: DateTime.yesterday
      )

      result = TokenUrl.valid?(token_url.token, notice)

      expect(result).to eq(false)
    end

    it 'validates successfully when the token hasn\'t expired' do
      token_url = create(
        :token_url,
        notice: notice,
        expiration_date: DateTime.tomorrow
      )

      result = TokenUrl.valid?(token_url.token, notice)

      expect(result).to eq(true)
    end

    it 'validates successfully when the token has expired, but the valid_forever flag is set' do
      token_url = create(
        :token_url,
        notice: notice,
        expiration_date: DateTime.yesterday,
        valid_forever: true
      )

      result = TokenUrl.valid?(token_url.token, notice)

      expect(result).to eq(true)
    end

    it 'validates unsuccessfully when the token or notice is nil' do
      result = TokenUrl.valid?(token_url.token, nil)

      expect(result).to eq(false)

      result = TokenUrl.valid?(nil, notice)

      expect(result).to eq(false)
    end
  end

  context 'destroying' do
    it 'destroys related token urls when the user/creator is destroyed' do
      user = create(:user)
      token_url = create(
        :token_url,
        notice: notice,
        user: user
      )
      token_url_2 = create(
        :token_url,
        notice: notice,
        user: user
      )

      expect(TokenUrl.where(id: [token_url.id, token_url_2.id]).count).to eq(2)

      user.destroy

      expect(TokenUrl.where(id: [token_url.id, token_url_2.id]).count).to eq(0)
    end

    it 'doesn\'t destroy related permanent token urls when the user/creator is destroyed' do
      user = create(:user)
      token_url = create(
        :token_url,
        notice: notice,
        user: user,
        valid_forever: true
      )
      token_url_2 = create(
        :token_url,
        notice: notice,
        user: user
      )

      expect(TokenUrl.where(id: [token_url.id, token_url_2.id]).count).to eq(2)

      user.destroy

      expect(TokenUrl.where(id: [token_url.id, token_url_2.id]).count).to eq(1)
      expect(TokenUrl.find(token_url.id)).to eq(token_url)
    end

    it 'doesn\'t destroy other user tokens' do
      user = create(:user)
      user_2 = create(:user)
      token_url = create(
        :token_url,
        notice: notice,
        user: user
      )
      token_url_2 = create(
        :token_url,
        notice: notice,
        user: user_2
      )

      expect(TokenUrl.where(id: [token_url.id, token_url_2.id]).count).to eq(2)

      user.destroy

      expect(TokenUrl.where(id: [token_url.id, token_url_2.id]).count).to eq(1)
      expect(TokenUrl.find(token_url_2.id)).to eq(token_url_2)
    end
  end
end
