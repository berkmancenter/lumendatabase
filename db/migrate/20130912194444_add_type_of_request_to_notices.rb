class AddTypeOfRequestToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column :notices, :request_type, :string
  end
end
