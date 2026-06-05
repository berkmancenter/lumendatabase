class CreateSettingForEnterpriseRegistrationAdminEmails < ActiveRecord::Migration[7.2]
  KEY = 'enterprise_registration_admin_emails'.freeze

  def up
    return if LumenSetting.find_by(key: KEY)

    LumenSetting.create!(
      name: 'Admin emails notified of new Lumen Enterprise registrations (comma separated)',
      key: KEY,
      value: 'team@lumendatabase.org'
    )
  end

  def down
    LumenSetting.where(key: KEY).destroy_all
  end
end
