class CreateReindexRuns < ActiveRecord::Migration[4.2]
  def change
    create_table :reindex_runs do |t|
      t.integer :entity_count, default: 0
      t.integer :notice_count, default: 0

      t.timestamps
    end

    add_index :reindex_runs, :created_at
    execute 'UPDATE entities set created_at = now()'
  end
end
