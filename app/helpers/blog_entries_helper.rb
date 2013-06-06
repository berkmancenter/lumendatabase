module BlogEntriesHelper
  def publishing_info(blog_entry)
    concat(blog_entry.author)

    if published_at = blog_entry.published_at
      concat(', ')
      time_tag(published_at, published_at.to_s(:simple))
    end
  end
end
