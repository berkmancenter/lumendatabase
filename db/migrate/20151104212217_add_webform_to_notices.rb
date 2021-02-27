class AddWebformToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column :notices, :webform, :boolean, default: false
  end
end
