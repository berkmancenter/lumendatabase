class CreateSettingForGithubEmail < ActiveRecord::Migration[7.1]
  def change
    LumenSetting.create!(
      name: 'Email to search for to find the exsting GitHub user',
      key: 'github_user_email',
      value: 'gh@email.com'
    )
  end
end
