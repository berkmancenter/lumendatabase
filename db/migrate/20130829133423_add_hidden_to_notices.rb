class AddHiddenToNotices < ActiveRecord::Migration
  def change
    add_column(:notices, :hidden, :boolean, default: false)
  end
end
