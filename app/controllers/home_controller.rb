class HomeController < ApplicationController
  layout 'home'

  def index
    # If you change versions of Rails, update the name of this cache key!
    # The new version may not be able to read objects serialized by the old
    # one.
    @notices = Rails.cache.fetch(
      'newest_notices', expires_in: 1.hour
    ) { Notice.visible.recent }
    @blog_entries = BlogEntry.recent_posts
  end
end
