class AddMarkRegistrationNumberToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column :notices, :mark_registration_number, :string
  end
end
