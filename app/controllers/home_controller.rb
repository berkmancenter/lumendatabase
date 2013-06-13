class HomeController < ApplicationController
  def index
    @notices = Notice.recent
    @blog_entries = BlogEntry.recent
  end
end
