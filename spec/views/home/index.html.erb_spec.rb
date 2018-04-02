require 'rails_helper'

describe 'home/index.html.erb' do
  let(:notices) { build_stubbed_list(:dmca, 3, date_received: 1.hour.ago) }
  let(:blog_entries) { build_stubbed_list(:blog_entry, 3) }

  before do
    assign(:notices, notices)
    assign(:blog_entries, blog_entries)
    assign(:tweet_news, [])

    render
  end

  it 'shows metadata and a link to each of its notices' do
    notices.each do |notice|
      expect( rendered ).to have_link( notice.title, href: notice_path(notice) )
      expect( rendered ).to have_css( "#notice_#{notice.id} time", text: notice.date_received.to_s(:simple) )
    end
  end

  it 'shows recent blog entries' do
    blog_entries.each do |blog_entry|
      expect( rendered ).to have_link( blog_entry.title, href: blog_entry_path(blog_entry) )
    end
  end
end
