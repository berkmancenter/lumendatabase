class AddLanguageToNotices < ActiveRecord::Migration
  def change
    add_column(:notices, :language, :string)
  end
end
