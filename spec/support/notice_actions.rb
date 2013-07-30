module NoticeActions
  def submit_recent_notice(title = "A title")
    visit "/notices/new?type=Notice"

    fill_in "Title", with: title
    fill_in "Date received", with: Time.now

    within('section.recipient') do
      fill_in "Name", with: "Recipient the first"
    end
    within('section.sender') do
      fill_in "Name", with: "Sender the first"
    end

    fill_in 'Work URL', with: 'http://www.example.com/original_work.pdf'
    fill_in 'Kind of Work', with: 'movie'
    fill_in 'Description', with: 'A series of videos and still images'
    fill_in 'Infringing URL', with: "http://example.com/infringing_url1"

    yield if block_given?

    click_on "Submit"
  end

  def open_recent_notice(title = "A title")
    within('#recent-notices') { click_on title }
  end

  def attach_notice_file(content)
    Tempfile.open('notice_file') do |fh|
      fh.write content
      fh.flush

      attach_file "Attach Notice", fh.path
    end
  end
end

RSpec.configure do |config|
  config.include NoticeActions, type: :request
end
