class RemoveTypeFromRiskTriggerCondition < ActiveRecord::Migration[4.2]
  def change
    remove_column :risk_trigger_conditions, :type
  end
end
