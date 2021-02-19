class ChangeInfringingUrlsWorksInfringingUrlIdToBigint < ActiveRecord::Migration[4.2]
  def change
    change_column :infringing_urls_works, :infringing_url_id, :bigint
  end
end

