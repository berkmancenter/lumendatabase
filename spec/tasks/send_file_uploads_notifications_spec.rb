require 'rails_helper'

describe 'rake lumen:send_file_uploads_notifications', type: :task do
  it 'sends file uploads notifications' do
    notice = create(:dmca)
    create(
      :token_url,
      email: 'user@example.com',
      documents_notification: true,
      notice: notice
    )
    create(
      :token_url,
      email: 'user2@example.com',
      documents_notification: false,
      notice: notice
    )
    create(:file_upload, kind: 'supporting', notice: notice)

    expect{ task.execute }.to change { ActionMailer::Base.deliveries.count }.by(1)

    email = ActionMailer::Base.deliveries.last

    expect(email.to).to include('user@example.com')
    expect(email.subject).to include("Documents updates for #{ notice.title }")

    expect{ task.execute }.to change { ActionMailer::Base.deliveries.count }.by(0)

    create(
      :token_url,
      email: 'user3@example.com',
      documents_notification: true,
      notice: notice
    )
    create(:file_upload, kind: 'supporting', notice: notice)

    expect{ task.execute }.to change { ActionMailer::Base.deliveries.count }.by(2)

    emails = ActionMailer::Base.deliveries.last(2)

    expect(emails.map(&:to).flatten).to eq(['user@example.com', 'user3@example.com'])
    expect(emails.map(&:subject).uniq).to eq(["Documents updates for #{ notice.title }"])
  end
end
