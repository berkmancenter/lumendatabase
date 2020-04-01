require 'rails_helper'

feature "Explanatory content on notice pages" do
  context "a first time visitor" do
    it "sees it", js: true do
      notice = create(:dmca)
      visit "/notices/#{notice.id}"

      expect(page).to have_css('.first-time-visitor')
    end

    it "can be manually hidden", js: true do
      notice = create(:dmca)
      visit "/notices/#{notice.id}"

      find("#hide-first-time-visitor-content a").click
      expect(page).to have_css('.first-time-visitor', visible: false)
    end
  end

  context "a repeat visitor" do
    it "does not see it", js: true do
      skip 'This test fails intermittently due to the time it takes to set cookies'
      notice = create(:dmca)
      visit "/notices/#{notice.id}"
      visit "/notices/#{notice.id}"
      expect(page).to have_no_css('.first-time-visitor')
    end
  end
end
