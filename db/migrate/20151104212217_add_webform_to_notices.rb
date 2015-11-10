class AddWebformToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :webform, :boolean, default: false
  end
end
