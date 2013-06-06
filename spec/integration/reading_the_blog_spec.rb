require 'spec_helper'

feature "The Blog" do
  scenario "A user reads a blog entry" do
    blog_entry = create(:blog_entry, :with_content)

    visit '/'
    click_on 'Weather Reports'
    click_on blog_entry.title

    expect(page.html).to include(blog_entry.content_html)
  end
end
