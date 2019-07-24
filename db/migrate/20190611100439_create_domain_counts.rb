class CreateDomainCounts < ActiveRecord::Migration
  def change
    create_table :domain_counts do |t|
      t.string :domain_name
      t.integer :count, default: 0

      t.timestamps null: false
    end
  end
end
