class AddSpamToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column :notices, :spam, :boolean, default: false
  end
end
