class CreateMatomoDimensionIdSettings < ActiveRecord::Migration[7.2]
  SETTINGS = [
    {
      name: 'Matomo action custom dimension ID for credential status',
      key: 'matomo_dimension_credential_status_id',
      value: '1'
    },
    {
      name: 'Matomo action custom dimension ID for authentication method',
      key: 'matomo_dimension_auth_method_id',
      value: '2'
    },
    {
      name: 'Matomo action custom dimension ID for usage surface',
      key: 'matomo_dimension_surface_id',
      value: '3'
    },
    {
      name: 'Matomo action custom dimension ID for authenticated user email',
      key: 'matomo_dimension_authenticated_user_email_id',
      value: '4'
    }
  ].freeze

  def up
    SETTINGS.each do |setting|
      next if LumenSetting.find_by(key: setting[:key])

      LumenSetting.create!(setting)
    end
  end

  def down
    LumenSetting.where(key: SETTINGS.map { |setting| setting[:key] }).destroy_all
  end
end
