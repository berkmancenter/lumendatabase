require 'spec_helper'

describe 'blog_entries/index.html.erb' do
  it "shows the publishing info for each entry" do
    blog_entries = mock_blog_entries

    render

    blog_entries.each do |blog_entry|
      expect(page).to have_content(blog_entry.author)
      expect(page).to have_content(blog_entry.published_at.to_s(:simple))
    end
  end

  it "has titles which are links to each entry" do
    blog_entries = mock_blog_entries

    render

    blog_entries.each do |blog_entry|
      expect(page).to contain_link(
        blog_entry_path(blog_entry), blog_entry.title
      )
    end
  end

  it "shows the entry's abstract" do
    blog_entries = mock_blog_entries

    render

    blog_entries.each do |blog_entry|
      expect(page).to have_content(blog_entry.abstract)
    end
  end

  it "renders abstracts via markdown" do
    blog_entries = mock_blog_entries do |blog_entries|
      blog_entries << create(
        :blog_entry, :published, abstract: "[A link](http://www.example.com)"
      )
    end

    render

    expect(page).to contain_link('http://www.example.com')
  end

  it "displays the URL for an entry that has a URL defined" do
    url = 'http://www.example.com'
    blog_entries = mock_blog_entries do |blog_entries|
      blog_entries << create(
        :blog_entry, :with_abstract, :published, url: url
      )
    end

    render

    expect(page).to contain_link(url)
  end

  def mock_blog_entries
    blog_entries = create_list(:blog_entry, 3, :with_abstract, :published)
    yield blog_entries if block_given?
    blog_entries.stub(:total_entries).and_return(blog_entries.length)
    blog_entries.stub(:total_pages).and_return(1)
    assign(:blog_entries, blog_entries)
    assign(:we_are_reading, [])
    blog_entries
  end
end
