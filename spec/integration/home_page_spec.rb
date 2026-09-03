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
    hidden_notice = build(:dmca, role_names: %w[submitter sender])
    hidden_notice.submitter.name = 'Google LLC'
    hidden_notice.sender.country_code = 'KR'
    hidden_notice.save!

    visit root_path

    recent_ids = Notice.visible.recent.pluck(:id)
    Notice.visible_for_display(recent_ids).each do |n|
      expect(page).to have_selector(:css, "a[href='#{notice_path(n.id)}']")
    end

    expect(page).not_to have_selector(
      :css, "a[href='#{notice_path(hidden_notice.id)}']"
    )

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
      Comfy::BlogPostFactory.new(site, layout, blog, seed: i).manufacture
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
