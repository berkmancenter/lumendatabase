class CreateContentFilters < ActiveRecord::Migration[6.1]
  def change
    create_table :content_filters do |t|
      t.string :name
      t.string :query
      t.text :notes
      t.jsonb :actions

      t.timestamps
    end
  end
end
