require 'rails_helper'

describe TokenUrlsMailer, type: :mailer do
  describe '.send_new_url_confirmation' do
    let(:notice) { build(:dmca) }
    let(:token_url) { build(:token_url) }
    let(:mail) { described_class.send_new_url_confirmation('user@example.com', token_url, notice).deliver_now }

    it 'sets the subject' do
      expect(mail.subject).to eq("Full notice access for #{notice.title}")
    end

    it 'sets the recipient' do
      expect(mail.to).to eq(['user@example.com'])
    end

    it 'sets the sender' do
      expect(mail.from).to eq([Chill::Application.config.default_sender])
    end

    it 'includes the token url in the body' do
      expect(mail.body.encoded).to match(
        notice_url(
          notice,
          access_token: token_url.token,
          host: Chill::Application.config.site_host
        )
      )
    end
  end
end
