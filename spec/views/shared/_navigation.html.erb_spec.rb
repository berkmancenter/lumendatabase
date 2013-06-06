require 'spec_helper'

describe 'shared/_navigation.html.erb' do
  it 'shows a link to create a new notice' do
    render

    expect(page).to contain_link(new_notice_path)
  end

  it 'has links to all categories' do
    categories = create_list(:category, 3)

    render

    categories.each do |category|
      expect(page).to contain_link(category_path(category))
    end
  end
end
