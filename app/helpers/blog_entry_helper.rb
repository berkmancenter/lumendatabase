module BlogEntryHelper
  def published_at(blog_entry)
    return unless (published_at = blog_entry.published_at)
    time_tag(published_at, published_at.to_s(:simple))
  end

  def blog_search_engine_configured?
    Chill::Application.config.google_custom_blog_search_id
  end
end
