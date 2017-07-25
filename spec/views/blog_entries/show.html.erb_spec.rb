require 'rails_helper'

describe 'blog_entries/show.html.erb' do
  it "shows the entry's title" do
    blog_entry = assign_blog_entry

    render

    expect(rendered).to have_content(blog_entry.title)
  end

  it "shows the entry's publishing info" do
    blog_entry = assign_blog_entry(:published)

    render

    expect(rendered).to have_content(blog_entry.author)
    expect(rendered).to have_content(blog_entry.published_at.to_s(:simple))
  end

  it "shows the entry's html content" do
    blog_entry = assign_blog_entry(:with_content)

    render

    expect(rendered).to include(blog_entry.content_html)
  end

  it "assigns the correct imagery class" do
    blog_entry = assign_blog_entry(image: 'rain')

    render

    expect(rendered).to have_css('.imagery.rain')
  end

  private

  def assign_blog_entry(*args)
    build(:blog_entry, *args).tap do |blog_entry|
      assign(:blog_entry, blog_entry)
    end
  end
end
