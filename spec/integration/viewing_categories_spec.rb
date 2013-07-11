require 'spec_helper'

feature "Categories" do
  scenario "a user views a category" do

    pending "@notices.any? returns true, but can't be enumerated over"

    category = create(:category)
    notice = create(:notice, :with_facet_data)
    notice.categories << category
    notice.save!

    visit '/'
    click_link(notice.title)
    within('section#categories') do
      click_link(category.name)
    end

  end
end
