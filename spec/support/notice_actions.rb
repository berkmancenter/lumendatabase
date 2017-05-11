module NoticeActions
  def submit_recent_notice(title = "A title")
    visit "/notices/new?type=DMCA"

    fill_in "Title", with: title
    fill_in "Date received", with: Time.now

    within('section.recipient') do
      fill_in "Name", with: "Recipient the first"
    end
    within('section.sender') do
      fill_in "Name", with: "Sender the first"
    end
    within('section.principal') do
      fill_in "Name", with: "Principal the first"
    end
    within('section.submitter') do
      fill_in "Name", with: "Submitter the first"
    end

    fill_in 'Work URL', with: 'http://www.example.com/original_work.pdf'
    fill_in 'Kind of Work', with: 'movie'
    fill_in 'Description', with: 'A series of videos and still images'
    fill_in 'Infringing URL', with: "http://example.com/infringing_url1"

    yield if block_given?

    click_on "Submit"
  end

  def open_recent_notice
    within('#recent-notices li:nth-child(1)') { find('a').click }
  end

  def attach_notice(content = "Some content")
    with_file(content) { |file| attach_file "Attach Notice", file.path }
  end

  def add_supporting_document(content = "Some content")
    @field_index ||= 0
    @field_index  += 1

    click_on "Attach another"

    field_name = "notice_file_uploads_attributes_#{@field_index}_file"

    with_file(content) do |file|
      attach_file field_name, file.path
    end
  end

  def with_file(content)
    Tempfile.open('file') do |file|
      file.write content
      file.flush

      yield(file)
    end
  end
end
