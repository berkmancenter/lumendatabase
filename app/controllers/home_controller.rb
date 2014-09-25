class HomeController < ApplicationController
  layout 'home'

  def index
    @notices = Notice.visible.recent
    @blog_entries = BlogEntry.recent
  end
end
