require 'spec_helper'

feature "Rails admin dashboard" do
  before do
    AdminOnPage.new(create(:user, :redactor)).tap do |user|
      user.sign_in
      user.visit_admin
    end
  end

  scenario "It displays proper labels for Notice subclasses in the sidebar" do
    within('.sidebar-nav') do
      expect(page).to have_css('a:contains(Notice)', 1)

      Notice.type_models.each do |model|
        expect(page).to have_css("a:contains('#{model.label}')")
      end
    end
  end

  scenario "It displays proper labels for Notice subclasses in the main list" do
    within('.content') do
      expect(page).to have_css('a:contains(Notice)', 1)

      Notice.type_models.each do |model|
        expect(page).to have_css("a:contains('#{model.label}')")
      end
    end
  end
end
