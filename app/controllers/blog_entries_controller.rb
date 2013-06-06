class BlogEntriesController < ApplicationController
  def index
    @blog_entries = BlogEntry.paginate(page: params[:page], per_page: 5)
  end

  def show
    @blog_entry = BlogEntry.find(params[:id])
  end
end
