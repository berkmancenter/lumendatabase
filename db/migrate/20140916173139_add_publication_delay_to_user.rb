class AddPublicationDelayToUser < ActiveRecord::Migration
  def up
    add_column :users, :publication_delay, :integer, default: 0, null: false
    User.all.select{|u| u.has_role? Role.submitter}.each do |u|
      u.email == 'admin@google.com' ? u.publication_delay = 10 * 24 * 60 * 60 : 0
    end
  end

  def down
    remove_column :users, :publication_delay
  end
end
