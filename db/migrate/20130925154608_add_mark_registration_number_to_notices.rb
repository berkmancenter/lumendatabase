class AddMarkRegistrationNumberToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :mark_registration_number, :string
  end
end
