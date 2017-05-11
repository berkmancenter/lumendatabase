class ChangeInfringingUrlsIdToBigint < ActiveRecord::Migration
  def change
    change_column :infringing_urls, :id, :bigint
  end
end
