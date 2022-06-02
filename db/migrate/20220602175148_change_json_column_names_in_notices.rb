class ChangeJsonColumnNamesInNotices < ActiveRecord::Migration[6.1]
  def change
    rename_column :notices, :tags_json, :tag_list
    rename_column :notices, :jurisdictions_json, :jurisdiction_list
    rename_column :notices, :regulations_json, :regulation_list
  end
end
