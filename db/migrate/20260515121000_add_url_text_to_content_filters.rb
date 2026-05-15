class AddUrlTextToContentFilters < ActiveRecord::Migration[6.1]
  def change
    add_column :content_filters, :url_text, :string
  end
end
