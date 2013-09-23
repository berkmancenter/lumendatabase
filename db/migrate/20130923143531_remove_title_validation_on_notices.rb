class RemoveTitleValidationOnNotices < ActiveRecord::Migration
  def change
    change_column :notices, :title, :string, null: true
  end
end
