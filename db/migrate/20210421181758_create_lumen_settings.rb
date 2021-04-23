class CreateLumenSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :lumen_settings do |t|
      t.string :name, null: false
      t.string :key, null: false
      t.string :value, null: false
    end

    LumenSetting.create!(
      name: 'Truncation token urls active period (in seconds)',
      key: 'truncation_token_urls_active_period',
      value: 86400
    )
  end
end
