require 'rails_helper'
require 'rss'

feature 'blog rss feed' do
  include ComfyHelpers
  include Comfy::CmsHelper
  include ERB::Util

  before :all do
    Rake::Task['lumen:set_up_cms'].execute
    @site = Comfy::Cms::Site.find_by_identifier('lumen_cms')
    @layout = Comfy::Cms::Layout.find_by_label('blawg')
    @blog = Comfy::Cms::Page.find_by_label('blog_entries')

    15.times do |i|
      BlogPostFactory.new(@site, @layout, @blog, seed: i).manufacture
    end
  end

  after :all do
    destroy_cms
  end

  it 'resolves at the expected URL' do
    visit '/blog_feed.rss'
    expect(page).to have_http_status(200)
  end

  it 'contains the latest content' do
    visit '/blog_feed.rss'

    @blog.children.last(10).each do |post|
      expect(page).to have_content cms_fragment_content('title', post)
      expect(page).to have_content cms_fragment_content('author', post)
      expect(page).to have_content post.created_at.to_s(:rfc822)
      expect(page).to have_content post.url
      expect(page).to have_content cms_fragment_content('content', post)
      expect(page).to have_content cms_fragment_content('abstract', post)
    end
  end

  # Not attempting to validate it against a schema here; just smoke-testing
  # that it is parseable as RSS. If it isn't, the parser will raise an
  # exception.
  it 'is probably valid' do
    visit '/blog_feed.rss'
    RSS::Parser.parse(page.body)
  end

  it 'is available from the home page' do
    visit '/'
    expect(page).to have_link(href: 'blog_feed.rss')
  end
end
