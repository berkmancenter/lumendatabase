class HomeController < ApplicationController
  layout 'home'

  def index
    @notices = Notice.recent
    @blog_entries = BlogEntry.recent
  end
end
