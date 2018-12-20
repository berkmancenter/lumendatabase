class BlogEntriesController < ApplicationController
  def index
    @blog_entries = BlogEntry.published.with_content.page(params[:page]).per(5)
    @we_are_reading = BlogEntry.published.we_are_reading.limit(5)
  end

  def archive
    @blog_entries = BlogEntry.archived.with_content.page(params[:page]).per(5)
    @we_are_reading = BlogEntry.published.we_are_reading.limit(5)
  end

  def show
    @blog_entry = BlogEntry.find(params[:id])
  end

  def feed
    @blog_articles = BlogEntry.published.with_content.limit(5)
    respond_to do |format|
      format.rss { render layout: false }
    end
  end
end
