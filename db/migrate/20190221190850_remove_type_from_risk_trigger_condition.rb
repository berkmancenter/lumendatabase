class RemoveTypeFromRiskTriggerCondition < ActiveRecord::Migration
  def change
    remove_column :risk_trigger_conditions, :type
  end
end
