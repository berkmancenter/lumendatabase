class ChangeScaleOfMentionToNotNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:media_mentions, :scale_of_mention, false)
  end
end
