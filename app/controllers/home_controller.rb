class HomeController < ApplicationController
  layout 'home'

  def index
    @notices = Notice.visible.recent
    @blog_entries = BlogEntry.published.with_content.first(5)
  end
end
