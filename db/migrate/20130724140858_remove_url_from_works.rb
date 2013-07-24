class RemoveUrlFromWorks < ActiveRecord::Migration
  def change
    remove_column :works, :url
  end
end
