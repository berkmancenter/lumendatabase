require 'spec_helper'

describe 'shared/_navigation.html.erb' do
  it 'shows a link to create a new notice' do
    render

    expect(page).to contain_link(new_notice_path)
  end

  it 'shows a link to read the blog' do
    render

    expect(page).to contain_link(blog_entries_path)
  end

  it 'has links to all categories' do
    categories = create_list(:category, 3)

    render

    categories.each do |category|
      expect(page).to contain_link(category_path(category))
    end
  end

  it 'shows categories in alphabetical order' do
    first_category = create(:category, name: 'AA category')
    third_category = create(:category, name: 'CC category')
    second_category = create(:category, name: 'BB category')

    render

    within('#dropdown-categories ol') do
      expect(page).to have_css('li:nth-child(1)', text: first_category.name)
      expect(page).to have_css('li:nth-child(2)', text: second_category.name)
      expect(page).to have_css('li:nth-child(3)', text: third_category.name)
    end
  end
end
