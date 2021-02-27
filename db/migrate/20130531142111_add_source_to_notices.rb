class AddSourceToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column(:notices, :source, :string)
  end
end
