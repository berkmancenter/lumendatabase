require 'spec_helper'

describe 'searches/show.html.erb' do
  it "display the results" do
    mock_results(build_list(:notice, 5))

    render

    expect(page).to have_css('.result', count: 5)
  end

  it "includes the notice data" do
    notice = create(
      :notice,
      role_names: ['recipient','submitter'],
      title: 'A notice',
      date_received: Time.now,
      categories: build_list(:category, 2)
    )
    mock_results([notice])

    render

    within('.result') do
      expect(page).to have_css('.title', text: 'A notice')
      expect(page).to have_css('.sender-receiver', text: notice.recipient.name)
      expect(page).to have_css('.sender-receiver', text: notice.submitter.name)
      expect(page).to have_css(
        '.date-received', text: notice.date_received.to_s(:simple)
      )
      within('.category') do
        notice.categories.each do |category|
          expect(page).to have_content(category.name)
        end
      end
      expect(page).to contain_link(notice_path(notice))
    end
  end

  it "includes excerpts" do
    notice = create(:notice)
    notice.stub(:highlight).and_return(
      stub(title: ['foo <em>bar</em> baz']).as_null_object
    )
    mock_results([notice])

    render

    within('.result') do
      expect(page).to have_content('foo bar baz')
    end
  end

  def mock_results(notices)
    notices.each do |notice|
      unless notice.respond_to?(:highlight)
        notice.stub(:highlight)
      end
    end
    notices.stub(:total_entries).and_return(notices.length)
    notices.stub(:total_pages).and_return(1)
    assign(:results, notices)
  end
end
