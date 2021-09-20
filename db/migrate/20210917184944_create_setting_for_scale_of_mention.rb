class CreateSettingForScaleOfMention < ActiveRecord::Migration[6.1]
  def change
    LumenSetting.create!(
      name: 'Possible values of scale of mention in media mentions',
      key: 'media_mentions_scale_of_mentions',
      value: 'Mentions Lumen,Links to Lumen,Notice-Focused,Lumen Research'
    )
  end
end
