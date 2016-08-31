class AddUrlCountToNotice < ActiveRecord::Migration
  def change
    add_column(:notices, :url_count, :integer)
  end
end
