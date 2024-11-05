class CreateSettingForGithubApiToken < ActiveRecord::Migration[7.2]
  def change
    LumenSetting.create!(
      name: 'Github API Token',
      key: 'github_api_token',
      value: 'token'
    )
  end
end
