require 'rails_helper'

feature "Topic lists as json" do
  scenario "an API consumer gets a list of topics" do
    create(:topic, name: 'A topic')
    create(:topic, name: 'Another topic')

    visit('/topics.json')

    json = JSON.parse(page.html)["topics"]

    expect(json.map{ |h| h['name'] }).to(
      match_array ['A topic', 'Another topic']
    )
  end
end
