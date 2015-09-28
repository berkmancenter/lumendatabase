class AddUrlOriginalToInfringingUrls < ActiveRecord::Migration
  def up
    add_column t, c, :string, limit: 8192
    execute "UPDATE #{t} SET #{c} = #{u}"
    change_column t, c, :string, null: false, limit: 8192
    remove_index t, u
    add_index t, c, unique: true
  end

  def down
    execute "UPDATE #{t} SET #{u} = #{c}"
    remove_column t, c
    add_index t, u, unique: true
  end

  def t
    :infringing_urls
  end

  def c
    :url_original
  end

  def u
    :url
  end
end
