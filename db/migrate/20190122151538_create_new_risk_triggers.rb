class CreateNewRiskTriggers < ActiveRecord::Migration
  def change
    # Create a new table
    create_table :risk_triggers do |t|
      t.string :name, null: false
      t.string :matching_type, null: false
      t.string :comment
    end

    # Add a reference field to the risk_trigger_conditions
    add_reference :risk_trigger_conditions, :risk_trigger, index: true

    # Create a default risk trigger
    default_risk_trigger = RiskTrigger.create(
      name: 'Default',
      matching_type: 'all'
    )

    # Assign all the exisiting conditions to the default trigger
    RiskTriggerCondition.update_all(risk_trigger_id: default_risk_trigger)
  end
end
