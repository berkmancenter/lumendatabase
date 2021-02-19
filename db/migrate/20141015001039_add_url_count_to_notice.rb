class AddUrlCountToNotice < ActiveRecord::Migration[4.2]
  def change
    add_column(:notices, :url_count, :integer)
  end
end
