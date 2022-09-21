class CreateTranslations < ActiveRecord::Migration[6.1]
  def change
    create_table :translations do |t|
      t.string :key
      t.text :notes
      t.text :body

      t.timestamps
    end

    execute File.read(File.expand_path('../sql/translations_initial.sql', __FILE__))
  end
end
