class CreateSettingForEnterpriseRegistrationDummyData < ActiveRecord::Migration[7.2]
  KEY = 'enterprise_registration_dummy_data_enabled'.freeze

  def up
    return if LumenSetting.find_by(key: KEY)

    LumenSetting.create!(
      name: 'Generate dummy notices for accepted Lumen Enterprise registrations',
      key: KEY,
      value: '0'
    )
  end

  def down
    LumenSetting.where(key: KEY).destroy_all
  end
end
