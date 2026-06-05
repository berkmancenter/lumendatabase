class CreateSettingForEnterpriseProPrice < ActiveRecord::Migration[7.2]
  KEY = 'enterprise_pro_price_usd'.freeze

  def up
    return if LumenSetting.find_by(key: KEY)

    LumenSetting.create!(
      name: 'Lumen Enterprise Pro price in US dollars, shown on the registration page',
      key: KEY,
      value: '500'
    )
  end

  def down
    LumenSetting.where(key: KEY).destroy_all
  end
end
