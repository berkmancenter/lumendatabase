class ChangeInfringingUrlsWorksInfringingUrlIdToBigint < ActiveRecord::Migration
  def change
    change_column :infringing_urls_works, :infringing_url_id, :bigint
  end
end

