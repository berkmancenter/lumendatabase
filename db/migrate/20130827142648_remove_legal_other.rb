class RemoveLegalOther < ActiveRecord::Migration
  def change
    remove_column :notices, :legal_other
    remove_column :notices, :legal_other_original
  end
end
