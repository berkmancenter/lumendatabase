class BlogEntriesController < ApplicationController
  def index
    @blog_entries = BlogEntry.published.with_content.paginate(
      page: params[:page], per_page: 5
    )
    @we_are_reading = BlogEntry.published.we_are_reading.limit(5)
  end

  def show
    @blog_entry = BlogEntry.find(params[:id])
  end
end
