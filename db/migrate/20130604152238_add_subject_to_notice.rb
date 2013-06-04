class AddSubjectToNotice < ActiveRecord::Migration
  def change
    add_column(:notices, :subject, :string)
  end
end
