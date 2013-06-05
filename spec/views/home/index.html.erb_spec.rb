require 'spec_helper'

describe 'home/index.html.erb' do

  it 'shows a link to create a new notice' do
    assign(:notices, [])

    render

    expect(page).to contain_link(new_notice_path)
  end

  it 'shows metadata and a link to each of its notices' do
    notices = build_stubbed_list(:notice, 3, date_received: 1.hour.ago)
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

  def contain_link(path)
    have_css(%{a[href="#{path}"]})
  end

end
