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
end
