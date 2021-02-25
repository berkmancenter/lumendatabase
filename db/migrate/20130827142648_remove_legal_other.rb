class RemoveLegalOther < ActiveRecord::Migration[4.2]
  def change
    remove_column :notices, :legal_other
    remove_column :notices, :legal_other_original
  end
end
