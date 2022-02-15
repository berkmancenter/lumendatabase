class AddJsonFieldToNotices < ActiveRecord::Migration[6.1]
  def change
    add_column :notices, :works_json, :jsonb
  end
end
