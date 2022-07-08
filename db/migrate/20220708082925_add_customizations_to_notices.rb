class AddCustomizationsToNotices < ActiveRecord::Migration[6.1]
  def change
    add_column :notices, :customizations, :jsonb
  end
end
