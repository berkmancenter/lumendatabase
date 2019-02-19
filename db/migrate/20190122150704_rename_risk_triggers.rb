class RenameRiskTriggers < ActiveRecord::Migration
  def change
    rename_table :risk_triggers, :risk_trigger_conditions
    remove_column :risk_trigger_conditions, :field
    rename_column :risk_trigger_conditions, :condition_field, :field
    rename_column :risk_trigger_conditions, :condition_value, :value
    add_column :risk_trigger_conditions, :type, :string
    add_column :risk_trigger_conditions, :matching_type, :string
    change_column_null :risk_trigger_conditions, :field, false
    change_column_null :risk_trigger_conditions, :value, false
  end
end
