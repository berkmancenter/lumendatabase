class CreateDataProtections < ActiveRecord::Migration
  def change
    create_table :data_protections do |t|

      t.timestamps
    end
  end
end
