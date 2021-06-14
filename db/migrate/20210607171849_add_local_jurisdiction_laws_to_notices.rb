class AddLocalJurisdictionLawsToNotices < ActiveRecord::Migration[6.0]
  def change
    add_column :notices, :local_jurisdiction_laws, :text
  end
end
