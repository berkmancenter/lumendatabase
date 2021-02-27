class AddTypeToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column(:notices, :type, :string)
    add_index(:notices, :type)
  end
end
