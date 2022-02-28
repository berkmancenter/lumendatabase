class AddCaseIdNumberToNotices < ActiveRecord::Migration[6.1]
  def change
    add_column :notices, :case_id_number, :integer, null: true
  end
end
