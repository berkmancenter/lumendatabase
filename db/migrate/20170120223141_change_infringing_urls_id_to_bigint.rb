class ChangeInfringingUrlsIdToBigint < ActiveRecord::Migration[4.2]
  def change
    change_column :infringing_urls, :id, :bigint
  end
end
