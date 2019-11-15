require 'rails_helper'

describe 'rake lumen:send_file_uploads_notifications', type: :task do
  let(:notice) { create(:dmca) }

  before(:each) { DocumentsUpdateNotificationNotice.destroy_all }

  it 'sends file uploads notifications to a single user' do
    create_token_with_enabled_notifications

    trigger_notification

    expect_to_deliver_specific_number_of_emails(1)

    expect(last_email.to).to include('user@example.com')
    expect(last_email.subject).to include("Documents updates for #{ notice.title }")
  end

  it 'sends file uploads notifications to multiple users' do
    create_token_with_enabled_notifications

    create(
      :token_url,
      documents_notification: true,
      notice: notice,
      email: 'user2@example.com'
    )
    trigger_notification

    expect_to_deliver_specific_number_of_emails(2)

    emails = ActionMailer::Base.deliveries.last(2)

    expect(emails.map(&:to).flatten).to eq(['user@example.com', 'user2@example.com'])
    expect(emails.map(&:subject).uniq).to eq(["Documents updates for #{ notice.title }"])
  end

  it "won't send duplicate notifications when the trigger has been run multiple times" do
    create_token_with_enabled_notifications

    trigger_notification
    trigger_notification

    expect_to_deliver_specific_number_of_emails(1)
  end

  it "won't send notifications again on the next task run" do
    create_token_with_enabled_notifications

    trigger_notification

    expect_to_deliver_specific_number_of_emails(1)
    expect_to_deliver_specific_number_of_emails(0)
  end

  it "won't send file uploads notifications for token urls with the document notification setting disabled" do
    create_token_with_enabled_notifications

    create(
      :token_url,
      documents_notification: false,
      notice: notice,
      email: 'user2@example.com'
    )
    trigger_notification

    expect_to_deliver_specific_number_of_emails(1)

    expect(last_email.to).to include('user@example.com')
  end

  private

  def trigger_notification
    create(:file_upload, kind: 'supporting', notice: notice)
  end

  def last_email
    ActionMailer::Base.deliveries.last
  end

  def expect_to_deliver_specific_number_of_emails(number)
    expect{ task.execute }.to change { ActionMailer::Base.deliveries.count }.by(number)
  end

  def create_token_with_enabled_notifications
    create(
      :token_url,
      documents_notification: true,
      notice: notice
    )
  end
end
