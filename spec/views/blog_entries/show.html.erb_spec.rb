require 'spec_helper'

describe 'blog_entries/show.html.erb' do
  it "shows the entry's title" do
    blog_entry = assign_blog_entry

    render

    expect(page).to have_content(blog_entry.title)
  end

  it "shows the entry's publishing info" do
    blog_entry = assign_blog_entry(:published)

    render

    expect(page).to have_content(blog_entry.author)
    expect(page).to have_content(blog_entry.published_at.to_s(:simple))
  end

  it "shows the entry's html content" do
    blog_entry = assign_blog_entry(:with_content)

    render

    expect(rendered).to include(blog_entry.content_html)
  end

  private

  def assign_blog_entry(*args)
    build(:blog_entry, *args).tap do |blog_entry|
      assign(:blog_entry, blog_entry)
    end
  end
end
