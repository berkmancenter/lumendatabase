class TokenUrlsMailer < ApplicationMailer
  def send_new_url_confirmation(recipient, token_url, notice)
    @token_url = token_url
    @notice = notice

    subject = "Full notice access for #{@notice.title}"

    mail(
      to: recipient,
      subject: subject
    )
  end
end
