class DocumentNotificationsMailer < ApplicationMailer
  def notice_file_uploads_updates_notification(recipient, notice, document_notification_email)
    @notice = notice
    @document_notification_email = document_notification_email

    subject = "Document updates for notice #{notice.id}"

    mail(
      to: recipient,
      subject: subject
    )
  end
end
