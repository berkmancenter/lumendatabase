class CreateNotices < ActiveRecord::Migration[4.2]
  def change
    create_table(:notices) do |t|
      t.string :title
      t.text :body
      t.datetime :date_sent
      t.timestamps
    end
  end
end
