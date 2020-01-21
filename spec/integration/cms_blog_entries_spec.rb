require 'rails_helper'
require 'comfy/blog_post_factory'

feature 'CMS blog entries' do
  include Comfy::ComfyHelper

  before :all do
    Comfy::Cms::Site.create!(identifier: 'lumen_cms', hostname: 'localhost')
    Rake::Task['comfy:cms_seeds:import'].execute(from: 'lumen_cms', to: 'lumen_cms')
    @site = Comfy::Cms::Site.first
    @layout = Comfy::Cms::Layout.find_by_label('blawg')
    @blog = Comfy::Cms::Page.find_by_label('blog_entries')
  end

  after :each do
    Comfy::Cms::Page.where.not(id: @blog.id).delete_all
    @blog.reload
  end

  context 'archive' do
    it 'paginates blog entries' do
      15.times do |i|
        BlogPostFactory.new(@site, @layout, @blog, seed: i).manufacture
      end

      visit @blog.url

      (0..9).each do |i|
        expect(page).to have_link("page_#{i}")
      end

      (10..14).each do |i|
        expect(page).not_to have_link("page_#{i}")
      end

      visit "#{@blog.url}?page=2"

      (0..9).each do |i|
        # Must use exact matching to prevent `page_1` from matching on
        # `page_10`, etc.
        expect(page).not_to have_link("page_#{i}", exact: true)
      end

      (10..14).each do |i|
        expect(page).to have_link("page_#{i}")
      end
    end

    it 'displays only published blog entries' do
      2.times do |i|
        BlogPostFactory.new(@site, @layout, @blog, seed: i).manufacture
      end
      @blog.children.where(label: 'page_1').update(is_published: false)

      visit @blog.url

      expect(page).to have_link('page_0')
      expect(page).not_to have_link('page_1')
    end

    it 'displays working links' do
      BlogPostFactory.new(@site, @layout, @blog, seed: 0).manufacture

      visit @blog.url

      click_link 'page_0'
      expect(page).to have_http_status(200)
    end

    it 'sorts by date descending' do
      2.times do |i|
        BlogPostFactory.new(@site, @layout, @blog, seed: i).manufacture
      end
      # Switch around the expected creation dates, to make sure we're sorting
      # on created_at and not id.
      @blog.children.first.update(created_at: 2.days.ago)
      @blog.children.second.update(created_at: 1.day.ago)

      visit @blog.url
      expect(find_all('h3.title a').map(&:text)).to eq \
        ['page_1', 'page_0']
    end

    it 'displays metadata' do
      BlogPostFactory.new(@site, @layout, @blog).manufacture
      post = @blog.children.first

      visit @blog.url

      expect(page.body).to include fragment_content(post, 'abstract')
      expect(page.body).to include fragment_content(post, 'author')
      expect(page.body).to include fragment_content(post, 'title')
      expect(page.body).to include blog_date(post)
    end
  end

  context 'post' do
    it 'loads a blog entry' do
      BlogPostFactory.new(@site, @layout, @blog).manufacture

      post = @blog.children.first
      visit post.url

      expect(page.body).to include(fragment_content(post, 'content'))
      expect(page.body).to include(fragment_content(post, 'author'))
      expect(page.body).to include(fragment_content(post, 'title'))
      expect(page.body).to include(blog_date(post))
    end
  end

  context 'admin' do
    context 'authentication' do
      it 'allows admin users' do
        sign_in(create(:user, :admin))
        visit comfy_admin_cms_path
        expect(page).to have_http_status(200)
      end

      it 'disallows non-admin users' do
        sign_in(create(:user))
        visit comfy_admin_cms_path
        expect(page.current_path).not_to eq comfy_admin_cms_path
      end

      it 'disallows anon users' do
        visit comfy_admin_cms_path
        expect(page.current_path).not_to eq comfy_admin_cms_path
      end
    end

    # These were tested for in the original BlogEntry. Here, testing them would
    # require going to the admin; changing the layout to blawg; and then
    # filling in the form without these and submitting. However, the capybara
    # select fails, and debugging it takes too long, so I'm leaving these here
    # in case future devs can make a better run at it.
    # This must be tested as an integration test through the admin stie because
    # it is validated only through form validation. --AY, 16 January 2020
    # context "automatic validations" do
    #   it { is_expected.to validate_presence_of(:author) }
    #   it { is_expected.to validate_presence_of(:title) }
    # end

  end

  def fragment_content(post, identifier)
    post.fragments.find_by_identifier(identifier).content
  end
end
