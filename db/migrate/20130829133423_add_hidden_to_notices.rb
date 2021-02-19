class AddHiddenToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column(:notices, :hidden, :boolean, default: false)
  end
end
