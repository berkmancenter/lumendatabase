require 'spec_helper'

feature "Searching via the API", search: true do
  before do
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true

    Tire.index(Notice.index_name).delete
  end

  scenario "the results array has relevant metadata" do
    create(:notice, title: "The Lion King on Youtube")
    expect_api_search_to_find("king") do |json|
      metadata = json['meta']
      expect(metadata).to have_key('current_page').with_value(1)
      expect(metadata).to have_key('next_page').with_value(nil)
      expect(metadata).to have_key('q').with_value("king")
      expect(json).to have_key('notices')
    end
  end

  scenario "a notice has relevant metadata" do
    category = create(:category, name: "Lion King")
    notice = create(
      :notice,
      categories: [category],
      title: "The Lion King on Youtube"
    )

    expect_api_search_to_find("king") do |json|
      json_item = json['notices'].first
      expect(json_item).to have_key('title').with_value(notice.title)
      expect(json_item).to have_key('id').with_value(notice.id.to_s)
      expect(json_item).to have_key('categories').with_value([category.name])
      expect(json_item).to have_key('score')
    end
  end

  def expect_api_search_to_find(term)
    sleep 1
    get('/search.json', { q: term })

    json = JSON.parse(response.body)
    yield(json) if block_given?
  end
end
