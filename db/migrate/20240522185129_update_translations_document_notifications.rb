class UpdateTranslationsDocumentNotifications < ActiveRecord::Migration[7.1]
  def change
    Translation
      .find_by(key: 'mailers_notice_file_uploads_notifications')
      .update(body: 'Hi,

You are getting this notification because documents have been updated for this notice: %{notice_id}.

This is a link to the notice: %{notice_link}.

Using this link you can download the documents.

To disable notifications about document updates click here: %{disable_notification_link}.

Thank you,
Lumen Database team
      ')

      Translation
        .create(
          key: 'notice_start_documents_notifications',
          body: 'Start watching notice'
        )

      Translation
        .create(
          key: 'notice_start_documents_notifications_tooltip',
          body: 'You will get email notifications when new notice documents are added.'
        )

      Translation
        .create(
          key: 'notice_stop_documents_notifications',
          body: 'Stop watching notice'
        )

      Translation
        .create(
          key: 'notice_stop_documents_notifications_tooltip',
          body: 'You will stop getting email notifications when new notice documents are added.'
        )
  end
end
