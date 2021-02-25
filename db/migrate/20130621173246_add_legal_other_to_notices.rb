class AddLegalOtherToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column(:notices, :legal_other, :text)
    add_column(:notices, :legal_other_original, :text)
  end
end
