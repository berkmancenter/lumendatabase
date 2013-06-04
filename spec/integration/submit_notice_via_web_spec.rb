require 'spec_helper'

feature "notice submission" do
  scenario "submitting a notice file" do
    submit_recent_notice("A title")

    expect(page).to have_css('#flash_notice')

    within("#recent-notices") do
      expect(page).to have_css(%{article:contains("A title")})
    end
  end

  scenario "submitting a notice with an attached file" do
    submit_recent_notice do
      attach_notice_file("Some content")
    end

    open_recent_notice

    expect(page).to have_content "Some content"
  end

  scenario "submitting a notice with tags" do
    submit_recent_notice do
      fill_in "Tag list", with: "tag_1, tag_2"
    end

    open_recent_notice

    within('#tags') do
      expect(page).to have_content "tag_1"
    end
  end

  scenario "submitting a notice with categories" do
    create(:category, name: "Category 1")
    create(:category, name: "Category 2")
    create(:category, name: "Category 3")

    submit_recent_notice do
      select "Category 1", from: "Categories"
      select "Category 3", from: "Categories"
    end

    open_recent_notice

    within('#categories') do
      expect(page).to have_content "Category 1"
      expect(page).to have_content "Category 3"
    end
  end

  scenario "submitting a notice with entities", js: true do
    submit_recent_notice do
      fill_in "Recipient Name", with: "Recipient the first"
      fill_in "Recipient Address Line 1", with: "Recipient Line 1"
      fill_in "Recipient Address Line 2", with: "Recipient Line 2"
      fill_in "Recipient City", with: "Recipient City"
      fill_in "Recipient State", with: "Recipient State"
      select "United States", from: "Recipient Country Code"

      fill_in "Submitter Name", with: "Submitter the first"
    end

    open_recent_notice

    within('#entities') do
      expect(page).to have_content "Recipient the first"
      expect(page).to have_content "Recipient Line 1"
      expect(page).to have_content "Recipient Line 2"
      expect(page).to have_content "Recipient City"
      expect(page).to have_content "Recipient State"
      expect(page).to have_content "United States"

      expect(page).to have_content "Submitter the first"
    end
  end

  scenario "submitting a notice with works" do
    submit_recent_notice do
      fill_in 'Work URL', with: 'http://www.example.com/original_work.pdf'
      fill_in 'Kind of Work', with: 'movie'
      fill_in 'Work Description', with: 'A series of videos and still images'
      fill_in 'Infringing URLs', with: "http://example.com/infringing_url1
http://example.com/infringing_url2"
    end

    open_recent_notice

    within('#works') do
      expect(page).to have_content 'http://www.example.com/original_work.pdf'
      expect(page).to have_content 'movie'
      expect(page).to have_content 'A series of videos and still images'
      expect(page).to have_css(
        %{.infringing_url:contains("http://example.com/infringing_url1")}
      )
      expect(page).to have_css(
        %{.infringing_url:contains("http://example.com/infringing_url2")}
      )
    end
  end

  scenario "submitting a notice with a source" do
    submit_recent_notice do
      fill_in "Sent via", with: "Arbitrary source"
    end

    open_recent_notice

    expect(page).to have_content "Sent via: Arbitrary source"
  end

  scenario "submitting a notice with a subject" do
    submit_recent_notice do
      fill_in "Subject", with: "Some subject"
    end

    open_recent_notice

    expect(page).to have_content "Re: Some subject"
  end

  scenario "a form articulates its required fields correctly" do
    visit "/submissions/new"

    within('form#new_submission') do
      expect(page).to have_css('input#submission_title.required')
      expect(page).to have_css('input#submission_date_received:not(.required)')
    end
  end

  scenario "submitting a notice without required fields present" do
    visit "/submissions/new"

    click_on "Submit"

    within('form .submission_title') do
      expect(page).to have_css('.error')
    end
  end

  private

  def submit_recent_notice(title = "A title")
    visit "/submissions/new"

    fill_in "Title", with: title
    fill_in "Date received", with: Time.now

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

      attach_file "Notice File", fh.path
    end
  end

end
