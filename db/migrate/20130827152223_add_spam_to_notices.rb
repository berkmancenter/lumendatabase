class AddSpamToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :spam, :boolean, default: false
  end
end
