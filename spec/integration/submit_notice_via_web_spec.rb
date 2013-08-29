require 'spec_helper'

feature "notice submission" do
  scenario "submitting a notice" do
    submit_recent_notice("A title")

    expect(page).to have_css('#flash_notice')

    within("#recent-notices") do
      expect(page).to have_css(%{li:contains("A title")})
    end
  end

  scenario "submitting a notice with language" do
    submit_recent_notice do
      select "en - English", from: "Language"
    end

    open_recent_notice

    notice = Notice.last
    expect(notice.language).to eq 'en'
  end

  scenario "submitting a notice with action taken" do
    submit_recent_notice do
      select "Yes", from: "Action taken"
    end

    open_recent_notice

    expect(page).to have_content("Action taken: Yes")
  end

  scenario "submitting a notice with a jurisdiction" do
    submit_recent_notice do
      fill_in "Jurisdiction", with: 'US, foobar'
    end

    open_recent_notice

    notice = Notice.last
    expect(notice.jurisdiction_list).to match_array ['US', 'foobar']
  end

  scenario "submitting a notice with dates" do
    submit_recent_notice do
      fill_in "Date sent", with: Time.local(2013, 5, 4)
      fill_in "Date received", with: Time.local(2013, 5, 5)
    end

    open_recent_notice

    within('.recipient .date') do
      expect(page).to have_content("May 05, 2013")
    end

    within('.sender .date') do
      expect(page).to have_content("May 04, 2013")
    end
  end

  scenario "submitting a notice with an original attached" do
    submit_recent_notice { attach_notice }

    open_recent_notice

    pending "We don't display originals yet"
  end

  scenario "submitting a notice with a supporting document", js: true do
    submit_recent_notice do
      add_supporting_document("Some supporting content")
    end

    open_recent_notice

    within('ol.attachments') do
      click_on "Supporting Document"

      # page.html is actually plain-text in this case
      expect(page.html).to eq "Some supporting content"
    end
  end

  scenario "submitting a notice with multiple supporting documents", js: true do
    submit_recent_notice do
      add_supporting_document
      add_supporting_document
      add_supporting_document
    end

    open_recent_notice

    within('ol.attachments') do
      expect(page).to have_css('li', 3)
    end
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

  scenario "submitting a notice with entities" do
    submit_recent_notice do
      within('section.recipient') do
        fill_in "Name", with: "Recipient the first"
        fill_in "Address Line 1", with: "Recipient Line 1"
        fill_in "Address Line 2", with: "Recipient Line 2"
        fill_in "City", with: "Recipient City"
        fill_in "State", with: "MA"
        select "United States", from: "Country"
      end

      within('section.sender') do
        fill_in "Name", with: "Sender the first"
      end
    end

    open_recent_notice

    within('#entities') do
      expect(page).to have_content "Recipient the first"
      expect(page).to have_content "[Private]"
      expect(page).to have_content "Recipient City"
      expect(page).to have_content "MA"
      expect(page).to have_content "US"

      expect(page).to have_content "Sender the first"
    end
  end

  scenario "entity addresses are partially private" do
    submit_recent_notice do
      within('section.recipient') do
        fill_in "Name", with: "Recipient the first"
        fill_in "Address Line 1", with: "Recipient Line 1"
        fill_in "Address Line 2", with: "Recipient Line 2"
        select "organization", from: "Recipient Kind"
      end

      within('section.sender') do
        fill_in "Name", with: "Sender the first"
        fill_in "Address Line 1", with: "Sender Line 1"
        fill_in "Address Line 2", with: "Sender Line 2"
      end
    end

    open_recent_notice

    within('#entities') do
      expect(page).not_to have_content "Recipient Line 1"
      expect(page).not_to have_content "Recipient Line 2"
      expect(page).not_to have_content "Sender Line 1"
      expect(page).not_to have_content "Sender Line 2"
      expect(page).not_to have_content "organization"
    end
  end

  scenario "submitting notices with duplicate items" do
    submit_recent_notice
    submit_recent_notice

    expect(Notice.count).to eq 2
    expect(Entity.count).to eq 2
    expect(Work.count).to eq 2
    expect(InfringingUrl.count).to eq 1
  end

  scenario "submitting a notice with works" do
    submit_recent_notice do
      fill_in 'Work URL', with: 'http://www.example.com/original_work.pdf'
      fill_in 'Description', with: 'A series of videos and still images'
      fill_in 'Infringing URL', with: "http://example.com/infringing_url1"
    end

    open_recent_notice

    within('#works') do
      expect(page).to have_content 'http://www.example.com/original_work.pdf'
      expect(page).to have_content 'movie'
      expect(page).to have_content 'A series of videos and still images'
      expect(page).to have_css(
        %{.infringing_url:contains("http://example.com/infringing_url1")}
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
    visit "/notices/new?type=Dmca"

    within('form#new_notice') do
      expect(page).to have_css('input#notice_title.required')
      expect(page).to have_css('input#notice_date_received:not(.required)')
    end
  end

  scenario "submitting a notice without required fields present" do
    visit "/notices/new?type=Dmca"

    click_on "Submit"

    within('form .notice_title') do
      expect(page).to have_css('.error')
    end
  end

end
