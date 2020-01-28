require 'rails_helper'
require 'uri'

describe 'lumen:migrate_original_news_id_redirects', type: :request do
  before(:all) do
    expect(BlogEntry.count).to eq 0
    create(
      :blog_entry,
      author: 'John Rock',
      title: 'Speech at Faneuil Hall',
      abstract: 'abstract goes here',
      image: 'overcast',
      content: 'content goes here',
      original_news_id: 1
    )
    Rake::Task['lumen:set_up_cms'].execute
    Rake::Task['lumen:migrate_blog_entries_to_cms'].execute
    Rake::Task['lumen:migrate_original_news_id_redirects'].execute
  end

  after(:all) do
    BlogEntry.destroy_all
  end

  it 'creates redirects for original news IDs' do
    get '/original_news_id/1'
    original_path = URI::parse(response.location).path

    page = Comfy::Cms::Page.find_by_full_path('/original_news_id/1')
    expect(page.target_page).to be_present

    # The full URL will not be the same because of namespacing under the CMS.
    # This is good -- it means we're not inadvertently testing our existing
    # controller. But the Comfy::Cms::Page.full_path attribute does not include
    # the namespacing.
    expect(page.target_page.full_path).to eq original_path
  end
end
