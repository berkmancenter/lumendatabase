class AddPublishedToNotice < ActiveRecord::Migration
  def up
    add_column :notices, :published, :boolean, default: true, null: false
    Notice.update_all(published: true)
  end

  def down
    remove_column :notices, :published
  end
end
