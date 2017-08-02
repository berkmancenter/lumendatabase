require 'rails_helper'
require 'blog_importer'

feature "Importing the blog from CSV" do
  before do
    ["Chilling Effects", "Fan Fiction", "Domain Names and Trademarks"].each do |topic|
      create(:topic, name: topic)
    end
    importer = BlogImporter.new('spec/support/example_files/blog_export.csv')
    importer.import
  end

  scenario "the correct number of blog entries are created" do
    expect(BlogEntry.count).to eq 7
  end

  scenario "blog entries are created with valid content" do
    entry = BlogEntry.first

    expect(entry.author).to eq 'Amita Guha, Salon.com'
    expect(entry.title).to eq 'Fingered by the movie cops'
    expect(entry.abstract).to eq "Under today's copyright laws, you are guilty until proven innocent. I know -- it happened to me.[A link](http://www.example.com)\n\n"
    expect(entry.content).to be_nil
    expect(entry.published_at).to eq DateTime.new(2001, 8, 30, 22, 53, 49, 'EDT')
    expect(entry.created_at).to eq DateTime.new(2001, 8, 30, 22, 53, 49, 'EDT')
    expect(entry.updated_at).to eq DateTime.new(2001, 12, 31, 16, 16, 48, 'EST')
    expect(entry.original_news_id).to eq 23
    expect(entry.topics).to eq Topic.where(name: 'Chilling Effects')
  end
end
