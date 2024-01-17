class ChangeNoticeTitleType < ActiveRecord::Migration[7.1]
  def change
    change_column :notices, :title, :text
  end
end
