require 'rails_helper'

describe 'rake lumen:archive_expired_token_urls', type: :task do
  it 'archives expired token urls' do
    expired_token_1 = create(:token_url, expiration_date: Time.now - 2.days)
    expired_token_2 = create(:token_url, expiration_date: Time.now - 2.days)
    expired_token_3 = create(:token_url, expiration_date: Time.now - 2.days)
    valid_token_1 = create(:token_url, expiration_date: Time.now + 2.days)

    expect(ArchivedTokenUrl.all.count).to eq 0
    expect(TokenUrl.all.count).to eq 4

    task.execute

    expect(ArchivedTokenUrl.all.count).to eq 3
    expect(ArchivedTokenUrl.all.pluck(:id)).to eq [expired_token_1.id, expired_token_2.id, expired_token_3.id]
    expect(TokenUrl.all.count).to eq 1
    expect(TokenUrl.all).to eq [valid_token_1]
  end

  it "won't archive forever valid token urls" do
    expired_token_1 = create(:token_url, expiration_date: Time.now - 2.days)
    expired_token_2 = create(:token_url, expiration_date: Time.now - 2.days)
    valid_token_1 = create(:token_url, expiration_date: Time.now - 2.days, valid_forever: true)
    valid_token_2 = create(:token_url, expiration_date: Time.now + 2.days)

    expect(ArchivedTokenUrl.all.count).to eq 0
    expect(TokenUrl.all.count).to eq 4

    task.execute

    expect(ArchivedTokenUrl.all.count).to eq 2
    expect(ArchivedTokenUrl.all.pluck(:id)).to eq [expired_token_1.id, expired_token_2.id]
    expect(TokenUrl.all.count).to eq 2
    expect(TokenUrl.all).to eq [valid_token_1, valid_token_2]
  end
end
