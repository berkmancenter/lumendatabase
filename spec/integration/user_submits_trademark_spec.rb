require 'spec_helper'

feature "Trademark notice type submission" do
  scenario "User submits and views a Trademark type notice" do
    visit '/'

    click_on 'Report Notice'
    click_on 'Trademark'

    fill_in "Title", with: "A title"
    fill_in "Mark", with: "My trademark (TM)"
    fill_in "Infringing URL", with: "http://example.com/infringing_url1"
    fill_in "Alleged Infringment", with: "They used my thing"
    within('section.recipient') do
      fill_in "Name", with: "Recipient"
    end
    within('section.sender') do
      fill_in "Name", with: "Sender"
    end

    click_on 'Submit'

    open_recent_notice

    expect(page).to have_content("Trademark - A title")
    within("#works") do
      expect(page).to have_content('Mark')
      expect(page).to have_content('My trademark (TM)')
    end
    within('.notice-show .main .body') do
      expect(page).to have_content('Alleged Infringment')
      expect(page).to have_content('They used my thing')
    end
  end
end
