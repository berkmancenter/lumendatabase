require 'spec_helper'

feature "notice submission" do
  scenario "submitting a notice without a file" do
    visit "/submissions/new"

    fill_in "Title", with: "A title"
    fill_in "Body", with: "A body"
    fill_in "Date sent", with: Time.now

    click_on "Submit"

    expect(page).to have_css('#flash_notice')

    within("#recent-notices") do
      expect(page).to have_css(%{article:contains("A title")})
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

    click_on "Submit"

    within("#recent-notices") do
      click_on "A title"
    end

    expect(page).to have_content "Some content"
  end

  scenario "submitting a notice with tags" do
    visit "/submissions/new"

    fill_in "Title", with: "A title"
    fill_in "Tag list", with: "tag_1, tag_2"
    click_on "Submit"

    visit notice_path(Notice.last)

    within('#tags') do
      expect(page).to have_content "tag_1"
    end
  end

  scenario "submitting a notice with categories" do
    create(:category, name: "Category 1")
    create(:category, name: "Category 2")
    create(:category, name: "Category 3")

    visit "/submissions/new"

    fill_in "Title", with: "A title"
    select "Category 1", from: "Categories"
    select "Category 3", from: "Categories"
    click_on "Submit"

    visit notice_path(Notice.last)

    within('#categories') do
      expect(page).to have_content "Category 1"
      expect(page).to have_content "Category 3"
    end
  end

  scenario "submitting a notice with entities", js: true do
    visit "/submissions/new"
    fill_in "Title", with: "A title"
    fill_in "Recipient Name", with: "Recipient the first"
    fill_in "Submitter Name", with: "Submitter the first"
    fill_in "Date sent", with: Time.now

    click_on "Submit"

    click_on 'A title'
    within('#entities') do
      expect(page).to have_content "Recipient the first"
      expect(page).to have_content "Submitter the first"
    end
  end

  scenario "a form articulates its required fields correctly" do
    visit "/submissions/new"

    within('form#new_submission') do
      expect(page).to have_css('input#submission_title.required')
      expect(page).to have_css('input#submission_date_sent:not(.required)')
    end
  end

  scenario "submitting a notice without required fields present" do
    visit "/submissions/new"

    click_on "Submit"

    within('form .submission_title') do
      expect(page).to have_css('.error')
    end
  end

end
