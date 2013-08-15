class AddTypeToNotices < ActiveRecord::Migration
  def change
    add_column(:notices, :type, :string)
    add_index(:notices, :type)
  end
end
