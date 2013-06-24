class AddLegalOtherToNotices < ActiveRecord::Migration
  def change
    add_column(:notices, :legal_other, :text)
    add_column(:notices, :legal_other_original, :text)
  end
end
