class CreateNoticeUpdateCall < ActiveRecord::Migration[6.1]
  def change
    create_table :notice_update_calls do |t|
      t.integer :caller_id
      t.string :caller_type
      t.string :status

      t.timestamps
    end
  end
end
