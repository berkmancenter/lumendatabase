require 'rails_helper'

feature 'home page' do
  include ComfyHelpers
  include Comfy::CmsHelper
  include Rails.application.routes.url_helpers

  # TODO: mock this out to save on setup.
  before :all do
    Rake::Task['lumen:set_up_cms'].execute
  end

  after :all do
    destroy_cms
  end

  it 'links to recent visible notices' do
    create_list(:dmca, 15)
    Notice.last(10).shuffle.take(5).map { |x| x.update(published: false) }

    visit root_path

    Notice.visible.recent.each do |n|
      expect(page).to have_selector(:css, "a[href='#{notice_path(n.id)}']")
    end

    Notice.first(5).each do |n|
      expect(page).not_to have_selector(:css, "a[href='#{notice_path(n.id)}']")
    end

    Notice.where(published: false).each do |n|
      expect(page).not_to have_selector(:css, "a[href='#{notice_path(n.id)}']")
    end
  end

  it 'displays recent blog entries' do
    site = Comfy::Cms::Site.find_by_identifier('lumen_cms')
    layout = Comfy::Cms::Layout.find_by_label('blawg')
    blog = Comfy::Cms::Page.find_by_label('blog_entries')
    15.times do |i|
      BlogPostFactory.new(site, layout, blog, seed: i).manufacture
    end

    visit root_path

    blog.children.last(5).each do |post|
      expect(page.body).to have_link(cms_fragment_content('title', post), exact: true)
    end

    blog.children.first(10).each do |post|
      expect(page.body).not_to have_link(cms_fragment_content('title', post), exact: true)
    end
  end
end
