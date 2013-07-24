class AddRescindedToNotices < ActiveRecord::Migration
  def change
    add_column(:notices, :rescinded, :boolean, null: false, default: false)
  end
end
