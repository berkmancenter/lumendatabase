require 'rails_helper'

describe 'lumen:migrate_blog_entries_to_cms', type: :request do
  include Rails.application.routes.url_helpers

  before(:all) do
    expect(BlogEntry.count).to eq 0
    create(
      :blog_entry,
      author: 'John Rock',
      title: 'Speech at Faneuil Hall',
      abstract: 'abstract goes here',
      image: 'overcast',
      content: 'content goes here'
    )
    Rake::Task['lumen:set_up_cms'].execute
    Rake::Task['lumen:migrate_blog_entries_to_cms'].execute
  end

  after(:all) do
    BlogEntry.destroy_all
  end

  let(:blog_parent) { Comfy::Cms::Page.find_by_label('blog_entries') }
  let(:post) { blog_parent.children.first }

  context 'importer' do
    it 'imports all blog entries' do
      expect(blog_parent.children.count).to eq 1

      original = BlogEntry.first

      expect(post.slug).to eq original.id.to_s
      expect(post.label).to eq original.title
      expect(post.created_at).to eq original.created_at
      expect(post.is_published).to be true

      expect(fragment_content(post, 'author')).to eq original.author
      expect(fragment_content(post, 'title')).to eq original.title
      expect(fragment_content(post, 'abstract')).to eq original.abstract_html
      expect(fragment_content(post, 'image')).to eq original.image
      expect(fragment_content(post, 'content')).to eq original.content_html
    end

    it 'is idempotent' do
      orig_entry_count = blog_parent.children.count
      Rake::Task['lumen:migrate_blog_entries_to_cms'].invoke
      expect(blog_parent.children.count).to eq orig_entry_count
    end
  end

  context 'individual blog entries' do
    it 'are available at expected URLs' do
      cms_blog_entry_path = blog_parent.children.first.full_path
      get cms_blog_entry_path
      expect(response).to be_successful
      expect(cms_blog_entry_path).to eq blog_entry_path(BlogEntry.first)
    end
  end

  def fragment_content(post, identifier)
    post.fragments.find_by_identifier(identifier).content
  end
end
