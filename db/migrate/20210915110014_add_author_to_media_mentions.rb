class AddAuthorToMediaMentions < ActiveRecord::Migration[6.1]
  def change
    add_column :media_mentions, :author, :string
  end
end
