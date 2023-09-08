class DropReindexRunTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :reindex_runs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
