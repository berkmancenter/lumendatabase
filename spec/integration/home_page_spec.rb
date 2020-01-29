require 'rails_helper'

feature 'home page' do
  include Rails.application.routes.url_helpers
  include Comfy::CmsHelper

  before :all do
    Rake::Task['lumen:set_up_cms'].execute
  end

  it 'links to recent visible notices' do
    create_list(:dmca, 15)
    Notice.last(10).shuffle.take(5).map { |x| x.update(published: false) }

    visit root_path

    links = page.all('li a').map { |a| a['href'] }

    Notice.visible.recent.each do |n|
      # Somehow the have_link syntax isn't working here. ¯\_(ツ)_/¯
      expect(links).to include(notice_path n.id)
    end

    Notice.first(5).each do |n|
      expect(links).not_to include(notice_path n.id)
    end

    Notice.where(published: false).each do |n|
      expect(links).not_to include(notice_path n.id)
    end
  end

  it 'displays recent blog entries' do
    visit root_path
    site = Comfy::Cms::Site.find_by_identifier('lumen_cms')
    layout = Comfy::Cms::Layout.find_by_label('blawg')
    blog = Comfy::Cms::Page.find_by_label('blog_entries')
    15.times do |i|
      BlogPostFactory.new(site, layout, blog, seed: i).manufacture
    end

    blog.children.last(5).each do |post|
      expect(page.body).to include cms_fragment_content('title', post)
    end

    blog.children.first(10).each do |post|
      expect(page.body).not_to include cms_fragment_content('title', post)
    end
  end
end
