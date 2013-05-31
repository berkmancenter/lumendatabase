class CreateWorks < ActiveRecord::Migration
  def change
    create_table(:works) do |t|
      t.string :url, limit: 1.kilobyte, null: false
      t.text :description
      t.timestamps
    end

    create_table(:notices_works, id: false) do |t|
      t.belongs_to :notice
      t.belongs_to :work
    end

    add_index :notices_works, :notice_id
    add_index :notices_works, :work_id
  end
end
