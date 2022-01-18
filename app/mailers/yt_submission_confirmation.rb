class YtSubmissionConfirmation < ApplicationMailer
  def yt_submission_confirmed(notice, email_address)
    @notice = notice

    subject = "Lumen Database submission given sID=#{@notice.id}"

    mail(
      to: email_address,
      subject: subject
    )
  end
end
