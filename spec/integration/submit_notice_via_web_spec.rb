require 'spec_helper'

feature "notice submission" do
  scenario "submitting a notice without a file" do
    visit "/submissions/new"

    fill_in "Title", with: "A title"
    fill_in "Body", with: "A body"
    fill_in "Date sent", with: Time.now

    click_on "Enter"

    expect(page).to have_css('#flash_notice')

    within("#recent-notices") do
      expect(page).to have_css(%{li:contains("A title")})
    end
  end

  scenario "submitting a notice with an attached file" do
    visit "/submissions/new"

    fill_in "Title", with: "A title"
    fill_in "Date sent", with: Time.now

    Tempfile.open("notice_file") do |fh|
      fh.write "Some content"
      fh.flush

      attach_file "Notice File", fh.path
    end

    click_on "Enter"

    within("#recent-notices") do
      click_on "A title"
    end

    expect(page).to have_content "Some content"
  end

  scenario "submitting a notice with tags" do
    visit "/submissions/new"

    fill_in "Title", with: "A title"
    fill_in "Tag list", with: "tag_1, tag_2"
    click_on "Enter"

    visit notice_path(Notice.last)

    within('#tags') do
      expect(page).to have_content "tag_1"
    end
  end

  scenario "a form articulates its required fields correctly" do
    visit "/submissions/new"

    within('form') do
      expect(page).to have_css('input#submission_title.required')
      expect(page).to have_css('input#submission_date_sent:not(.required)')
    end
  end

  scenario "submitting a notice without required fields present" do
    visit "/submissions/new"

    click_on "Enter"

    within('form .submission_title') do
      expect(page).to have_css('.error')
    end
  end

end
