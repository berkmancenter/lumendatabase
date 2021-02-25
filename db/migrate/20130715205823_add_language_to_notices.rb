class AddLanguageToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column(:notices, :language, :string)
  end
end
