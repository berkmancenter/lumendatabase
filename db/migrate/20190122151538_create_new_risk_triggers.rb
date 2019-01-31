class CreateNewRiskTriggers < ActiveRecord::Migration
  def change
    # Create a new table
    create_table :risk_triggers do |t|
      t.string :name, null: false
      t.string :matching_type, null: false
      t.string :comment
      t.boolean :force_not_risky_assessment, default: false, null: false
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

    # Create a risk trigger and its conditions from the ones that were hard-coded in the RiskTrigger model
    google_risk_trigger = RiskTrigger.create(
      name: 'Google Defamation',
      matching_type: 'all',
      force_not_risky_assessment: true
    )
    RiskTriggerCondition.create(
      field: 'notice.type',
      value: 'Defamation',
      negated: false,
      risk_trigger: google_risk_trigger,
      matching_type: 'exact'
    )
    RiskTriggerCondition.create(
      field: 'submitter.email',
      value: 'google@lumendatabase.org',
      negated: false,
      risk_trigger: google_risk_trigger,
      matching_type: 'exact'
    )
  end
end
