module BlogEntryHelper
  def published_at(blog_entry)
    if published_at = blog_entry.published_at
      time_tag(published_at, published_at.to_s(:simple))
    end
  end
end
