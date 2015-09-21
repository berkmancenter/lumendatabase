class AddDescriptionOriginalToWorks < ActiveRecord::Migration
  def up
    add_column t, c, :text
    execute "UPDATE #{t} SET #{c} = #{d}"
  end

  def down
    execute "UPDATE #{t} SET #{d} = #{c}"
    remove_column t, c
  end

  def t
    :works
  end

  def c
    :description_original
  end

  def d
    :description
  end
end
