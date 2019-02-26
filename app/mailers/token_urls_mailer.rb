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

  def notice_file_uploads_updates_notification(recipient, token_url, notice)
    @token_url = token_url
    @notice = notice

    subject = "Documents updates for #{@notice.title}"

    mail(
      to: recipient,
      subject: subject
    )
  end
end
