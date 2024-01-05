class BlogFeedController < ApplicationController
  include Comfy::CmsHelper

  def index
    setup_blog_articles
    respond_to do |format|
      format.rss { render :layout => false }
    end
  end

  def setup_blog_articles
    @blog_articles = []
    latest_blog_posts.each do |post|
      @blog_articles << articleify(post)
    end
  end

  private

  def latest_blog_posts
    Comfy::Cms::Page.find_by_label('blog_entries')
                    .children
                    .last(10)
                    .reverse
  rescue NoMethodError # when blog_entries undefined, or no children
    []
  end

  def articleify(post)
    OpenStruct.new(
      title: cms_fragment_content('title', post),
      author: cms_fragment_content('author', post),
      pubDate: post.created_at.to_fs(:rfc822),
      link: post.url,
      guid: post.id.to_s,
      content: cms_fragment_content('content', post),
      description: cms_fragment_content('abstract', post)
    )
  end
end
