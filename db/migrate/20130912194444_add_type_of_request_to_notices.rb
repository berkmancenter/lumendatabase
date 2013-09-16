class AddTypeOfRequestToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :request_type, :string
  end
end
