class RemoveUrlFromWorks < ActiveRecord::Migration[4.2]
  def change
    remove_column :works, :url
  end
end
