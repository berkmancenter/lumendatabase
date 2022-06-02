class AddJsonFieldsForTaggingsToNotices < ActiveRecord::Migration[6.1]
  def change
    add_column :notices, :tags_json, :jsonb
    add_column :notices, :jurisdictions_json, :jsonb
    add_column :notices, :regulations_json, :jsonb
  end
end
