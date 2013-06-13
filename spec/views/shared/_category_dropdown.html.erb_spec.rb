require 'spec_helper'

describe 'shared/_category_dropdown.html.erb' do
  it 'shows children in alphabetical order' do
    root = create(:category, name: 'Root')
    first_category = create(:category, name: 'AA category', parent: root)
    third_category = create(:category, name: 'CC category', parent: root)
    second_category = create(:category, name: 'BB category', parent: root)

    render 'shared/category_dropdown', category: root

    within('ol') do
      expect(page).to have_css('li:nth-child(2)', text: first_category.name)
      expect(page).to have_css('li:nth-child(3)', text: second_category.name)
      expect(page).to have_css('li:nth-child(4)', text: third_category.name)
    end
  end
end
