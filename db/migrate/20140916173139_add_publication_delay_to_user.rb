class AddPublicationDelayToUser < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :publication_delay, :integer, default: 0, null: false
    User.all.each do |u|
      if ['admin@google.com', 'google@chillingeffects.org'].include?(u.email)
        u.update_attribute(:publication_delay, 10 * 24 * 60 * 60)
      end
    end
  end

  def down
    remove_column :users, :publication_delay
  end
end
