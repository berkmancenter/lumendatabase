require 'spec_helper'

feature "Categories" do
  scenario "user views a category", search: true do
    category = create(:category, name: 'An awesome name')
    notice = create(:notice, categories: [category])

    sleep 2

    visit "/categories/#{category.id}"

    within('section.category-notices') do
      expect(page).to have_content notice.title
    end
  end
end
