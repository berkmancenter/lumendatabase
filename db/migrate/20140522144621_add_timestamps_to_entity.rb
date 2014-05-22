class AddTimestampsToEntity < ActiveRecord::Migration
  def change
    change_table(:entities) do |t|
      t.timestamps
    end

    execute 'UPDATE entities set updated_at = now()'

    add_index :entities, :updated_at
  end
end
