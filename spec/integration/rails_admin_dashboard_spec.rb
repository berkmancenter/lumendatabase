require 'spec_helper'

feature "Rails admin dashboard" do
  before do
    AdminOnPage.new(create(:user)).tap do |user|
      user.sign_in
      user.visit_admin
    end
  end

  scenario "It displays proper labels for Notice subclasses in the sidebar" do
    within('.sidebar-nav') do
      expect(page).to have_css('a:contains(Notice)', 1)

      Notice::TYPES.each do |_, type_label|
        expect(page).to have_css("a:contains('#{type_label}')")
      end
    end
  end

  scenario "It displays proper labels for Notice subclasses in the main list" do
    within('.content') do
      expect(page).to have_css('a:contains(Notice)', 1)

      Notice::TYPES.each do |_, type_label|
        expect(page).to have_css("a:contains('#{type_label}')")
      end
    end
  end
end
