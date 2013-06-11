require 'spec_helper'

feature "Category lists as json" do
  scenario "an API consumer gets a list of categories" do
    create(:category, name: 'A category')
    create(:category, name: 'Another category')

    visit('/categories.json')

    json = JSON.parse(page.html)["categories"]

    expect(json.map{ |h| h['name'] }).to(
      match_array ['A category', 'Another category']
    )
  end
end
