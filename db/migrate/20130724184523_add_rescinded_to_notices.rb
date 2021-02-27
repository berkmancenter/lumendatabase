class AddRescindedToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column(:notices, :rescinded, :boolean, null: false, default: false)
  end
end
