class AddTimestampsToMultipleTables < ActiveRecord::Migration[6.1]
  def change
    change_table :file_uploads do |t|
      timestamps_with_null t
    end

    change_table :lumen_settings do |t|
      timestamps_with_null t
    end

    change_table :topics do |t|
      timestamps_with_null t
    end

    change_table :roles do |t|
      timestamps_with_null t
    end

    change_table :risk_triggers do |t|
      timestamps_with_null t
    end

    change_table :risk_trigger_conditions do |t|
      timestamps_with_null t
    end

    change_table :relevant_questions do |t|
      timestamps_with_null t
    end
  end

  private

  def timestamps_with_null(t)
    t.timestamps null: true
  end
end
