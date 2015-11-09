class BlankWorkKinds < ActiveRecord::Migration
  def up
  	Work.update_all(kind: nil)
  end

  def down
  end
end
