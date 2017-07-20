require 'rails_helper'

feature "Explanatory content on notice pages" do
  context "a first time visitor" do
    it "sees it", js: true do
      notice = create(:dmca)
      visit "/notices/#{notice.id}"

      sleep 0.2
      expect(page).to have_css('.first-time-visitor')
    end

    it "can be manually hidden", js: true do
      notice = create(:dmca)
      visit "/notices/#{notice.id}"
      sleep 0.2

      find("#hide-first-time-visitor-content a").click
      sleep 0.2
      expect(page).to have_css('.first-time-visitor', visible: false)
    end
  end

  context "a repeat visitor" do
    it "does not see it", js: true do
      notice = create(:dmca)
      visit "/notices/#{notice.id}"
      sleep 0.2
      visit "/notices/#{notice.id}"
      expect(page).to have_no_css('.first-time-visitor')
    end
  end
end
