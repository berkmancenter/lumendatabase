class AddSourceToNotices < ActiveRecord::Migration
  def change
    add_column(:notices, :source, :string)
  end
end
