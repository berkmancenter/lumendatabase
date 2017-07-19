require 'rails_helper'

describe 'home/index.html.erb' do
  before do
    assign(:notices, [])
    assign(:blog_entries, [])
    assign(:tweet_news, [])
  end

  it 'shows metadata and a link to each of its notices' do
    notices = build_stubbed_list(:dmca, 3, date_received: 1.hour.ago)
    assign(:notices, notices)

    render

    notices.each do |notice|
      within("#notice_#{notice.id}") do
        expect(page).to have_content notice.title
        expect(page).to have_content notice.date_received.to_s(:simple)
        expect(page).to contain_link notice_path(notice)
      end
    end
  end

  it 'shows recent blog entries' do
    blog_entries = build_stubbed_list(:blog_entry, 3)
    assign(:blog_entries, blog_entries)

    render

    blog_entries.each do |blog_entry|
      within("#blog_entry_#{blog_entry.id}") do
        expect(page).to have_content blog_entry.title
        expect(page).to contain_link blog_entry_path(blog_entry)
      end
    end
  end
end
