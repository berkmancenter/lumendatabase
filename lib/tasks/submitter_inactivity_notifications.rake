namespace :lumen do
  desc 'Notify configured addresses when submitters have been inactive too long'
  task send_submitter_inactivity_notifications: :environment do
    notification_count = Lumen::SubmitterInactivityNotifier.call

    Rails.logger.info(
      "[rake lumen:send_submitter_inactivity_notifications] " \
      "Queued #{notification_count} notification(s)"
    )
  end
end
