class AddPublishedToNotice < ActiveRecord::Migration
  def up
    add_column :notices, :published, :boolean, default: true, null: false
    Notice.all.each{ |n| n.published = true; n.save! }
  end

  def down
    remove_column :notices, :published
  end
end
