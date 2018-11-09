require 'spec_helper'

describe TokenUrl, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:notice) }

  context '#generate_token' do
    it 'generates a token on token url creation' do
      token_url = TokenUrl.create(email: 'user@example.com')

      expect(token_url.token).not_to be_empty
    end
  end
end
