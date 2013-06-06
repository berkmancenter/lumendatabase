require 'spec_helper'

describe 'shared/_category_list.html.erb' do
  it "includes links to each category by name" do
    categories = build_stubbed_list(:category, 3)

    render 'shared/category_list', categories: categories

    categories.each do |category|
      expect(page).to contain_link(category_path(category), category.name)
    end
  end

  it "builds the comma-separated list correctly" do
    categories = build_stubbed_list(:category, 3)

    render 'shared/category_list', categories: categories

    expect(page).to have_content(/^#{categories.map(&:name).join(', ')}$/)
  end
end
