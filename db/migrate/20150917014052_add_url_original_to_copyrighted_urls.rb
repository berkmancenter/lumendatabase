class AddUrlOriginalToCopyrightedUrls < ActiveRecord::Migration
  def change
    rename_index t, "index_#{t}_on_#{u}", "index_#{t}_on_#{c}"
    rename_column t, u, c
    add_column t, u, :string, limit: 8192
    puts "don't forget to (outside rails): UPDATE #{t} SET #{u} = #{c}"
  end

  def t
    :copyrighted_urls
  end

  def c
    :url_original
  end

  def u
    :url
  end
end
