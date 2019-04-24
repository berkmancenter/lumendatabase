class HomeController < ApplicationController
  layout 'home'

  def index
    @notices = Rails.cache.fetch(
      'recent_notices', expires_in: 1.hour
    ) { Notice.visible.recent }
    @blog_entries = BlogEntry.recent_posts
  end
end
