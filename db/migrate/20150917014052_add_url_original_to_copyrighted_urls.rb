class AddUrlOriginalToCopyrightedUrls < ActiveRecord::Migration
  def change
    rename_column t, u, c
    rename_index t, "index_#{t}_on_#{u}", "index_#{t}_on_#{c}"
    add_column t, u, :string, null: false, limit: 8192
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
