class AddGranularityToContentFilters < ActiveRecord::Migration[6.1]
  def change
    add_column :content_filters, :granularity, :string, null: false, default: 'notice'
  end
end
