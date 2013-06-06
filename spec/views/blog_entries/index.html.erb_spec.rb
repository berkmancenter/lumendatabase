require 'spec_helper'

describe 'blog_entries/index.html.erb' do
  it "shows the publishing info for each entry" do
    blog_entries = create_list(:blog_entry, 3, :published)
    assign(:blog_entries, blog_entries)

    render

    blog_entries.each do |blog_entry|
      expect(page).to have_content(blog_entry.author)
      expect(page).to have_content(blog_entry.published_at.to_s(:simple))
    end
  end

  it "has titles which are links to each entry" do
    blog_entries = create_list(:blog_entry, 3)
    assign(:blog_entries, blog_entries)

    render

    blog_entries.each do |blog_entry|
      expect(page).to contain_link(
        blog_entry_path(blog_entry), blog_entry.title
      )
    end
  end

  it "shows the entry's abstract" do
    blog_entries = create_list(:blog_entry, 3, :with_abstract)
    assign(:blog_entries, blog_entries)

    render

    blog_entries.each do |blog_entry|
      expect(page).to have_content(blog_entry.abstract)
    end
  end
end
