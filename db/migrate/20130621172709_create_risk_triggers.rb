class CreateRiskTriggers < ActiveRecord::Migration
  def change
    create_table(:risk_triggers) do |t|
      t.string :field
      t.string :condition_field
      t.string :condition_value
      t.boolean :negated
    end
  end
end
