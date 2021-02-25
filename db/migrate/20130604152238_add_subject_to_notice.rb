class AddSubjectToNotice < ActiveRecord::Migration[4.2]
  def change
    add_column(:notices, :subject, :string)
  end
end
