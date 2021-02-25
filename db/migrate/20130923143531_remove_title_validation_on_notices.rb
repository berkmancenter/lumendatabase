class RemoveTitleValidationOnNotices < ActiveRecord::Migration[4.2]
  def change
    change_column :notices, :title, :string, null: true
  end
end
