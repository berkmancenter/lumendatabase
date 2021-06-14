class AddYoutubeImports < ActiveRecord::Migration[5.2]
  def change
    create_table :yt_imports do |t|
      t.timestamps
    end
  end
end
