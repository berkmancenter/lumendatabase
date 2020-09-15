require 'comfy/blog_post_factory'
require 'rails_helper'
require 'rss'

feature 'CMS blog entries' do
  include ComfyHelpers
  include Comfy::ComfyHelper
  include Comfy::CmsHelper
  include ERB::Util

  # Try to put all CMS integration specs in this file, so that we only need to
  # do this costly setup once.
  before :all do
    Rake::Task['lumen:set_up_cms'].execute
    @site = Comfy::Cms::Site.find_by_identifier('lumen_cms')
    @layout = Comfy::Cms::Layout.find_by_label('blawg')
    @blog = Comfy::Cms::Page.find_by_label('blog_entries')
  end

  after :each do
    @blog.children.destroy_all
  end

  after :all do
    destroy_cms
  end

  context 'archive' do
    it 'paginates blog entries' do
      15.times do |i|
        BlogPostFactory.new(@site, @layout, @blog, seed: i).manufacture
      end

      @blog.reload
      visit @blog.full_path

      (0..9).each do |i|
        expect(page).to have_link("page_#{i}", exact: true)
      end

      (10..14).each do |i|
        expect(page).not_to have_link("page_#{i}", exact: true)
      end

      visit "#{@blog.full_path}?page=2"

      (0..9).each do |i|
        # Must use exact matching to prevent `page_1` from matching on
        # `page_10`, etc.
        expect(page).not_to have_link("page_#{i}", exact: true)
      end

      (10..14).each do |i|
        expect(page).to have_link("page_#{i}", exact: true)
      end
    end

    it 'displays only published blog entries' do
      2.times do |i|
        BlogPostFactory.new(@site, @layout, @blog, seed: i).manufacture
      end
      @blog.children.where(label: 'page_1').update(is_published: false)

      @blog.reload
      visit @blog.full_path

      expect(page).to have_link('page_0', exact: true)
      expect(page).not_to have_link('page_1', exact: true)
    end

    it 'displays working links' do
      BlogPostFactory.new(@site, @layout, @blog, seed: 0).manufacture

      @blog.reload
      visit @blog.full_path

      click_link 'page_0'
      expect(page).to have_http_status(200)
    end

    it 'sorts by date descending' do
      2.times do |i|
        BlogPostFactory.new(@site, @layout, @blog, seed: i).manufacture
      end
      @blog.reload
      # Switch around the expected creation dates, to make sure we're sorting
      # on created_at and not id.
      @blog.children.first.update(created_at: 2.days.ago)
      @blog.children.second.update(created_at: 1.day.ago)

      visit @blog.full_path
      expect(find_all('h3.title a').map(&:text)).to eq \
        ['page_1', 'page_0']
    end

    it 'displays metadata' do
      post = new_post

      visit @blog.full_path

      expect(page.body).to include cms_fragment_content('abstract', post)
      expect(page.body).to include cms_fragment_content('author', post)
      expect(page.body).to include cms_fragment_content('post_title', post)
      expect(page.body).to include blog_date(post)
    end

    it 'displays formatted html' do
      post = new_post

      expect(cms_fragment_content('abstract', post)).to include('<p>')

      visit @blog.full_path
      expect(page.body).not_to include '&lt;p&gt;'
    end

    it 'does not embed the custom search engine when not configured' do
      visit @blog.full_path

      expect(page.body).not_to have_custom_search_engine_embed
    end

    it 'has a custom search engine' do
      allow(Chill::Application.config).to receive(:google_custom_blog_search_id).and_return('yep')

      visit @blog.full_path

      expect(page.body).to have_custom_search_engine_embed
    end
  end

  context 'post' do
    it 'loads a blog entry' do
      post = new_post

      visit post.full_path

      image = cms_fragment_content('image', post)

      expect(page.body).to include(cms_fragment_content('post_content', post))
      expect(page.body).to include(cms_fragment_content('author', post))
      expect(page.body).to include(cms_fragment_content('post_title', post))
      expect(page.body).to include(blog_date(post))
      expect(page.body).to have_css(".imagery.#{image}")
    end

    it 'displays formatted html' do
      post = new_post


      expect(cms_fragment_content('content', post)).to include('<p>')

      visit post.full_path
      expect(page.body).not_to include '&lt;p&gt;'
    end

    it 'routes original_news_ids' do
      post = new_post

      parent = Comfy::Cms::Page.create(
                                  site: @site,
                                  layout: @layout,
                                  label: 'original news ID parent',
                                  slug: 'original_news_id',
                                  is_published: false
                                )

       Comfy::Cms::Page.create(
                          site: @site,
                          layout: @layout,
                          parent: parent,
                          label: "redirect_1",
                          slug: 1,
                          target_page: Comfy::Cms::Page.find_by_slug(post.id)
                        )
       visit '/original_news_id/1'
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

  context 'user' do
    it 'reads a blog entry' do
      blog_entry = new_post

      visit '/blog_entries'
      click_on cms_fragment_content('title', blog_entry)

      expect(page.body).to include(cms_fragment_content('content', blog_entry))
    end

    it 'opens a blog entry from the home page' do
      blog_entry = new_post

      visit '/'
      click_on cms_fragment_content('title', blog_entry)

      expect(current_path).to eq blog_entry.full_path
    end
  end

  context 'feed' do
    before :all do
      15.times do |i|
        BlogPostFactory.new(@site, @layout, @blog, seed: i).manufacture
      end
    end

    after :all do
      @blog.children.delete_all
    end

    it 'resolves at the expected URL' do
      visit '/blog_feed.rss'
      expect(page).to have_http_status(200)
    end

    it 'contains the latest content' do
      visit '/blog_feed.rss'

      @blog.reload
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

  def have_custom_search_engine_embed
    have_css('.blog-search')
  end

  def new_post
    BlogPostFactory.new(@site, @layout, @blog).manufacture
    @blog.reload # critical to avoid intermittent failures
    @blog.children.first
  end
end
