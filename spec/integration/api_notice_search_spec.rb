require 'spec_helper'

feature "Searching for Notices via the API" do
  include CurbHelpers

  scenario "the results array has relevant metadata", js: true, search: true do
    create(:notice, title: "The Lion King on Youtube")
    expect_api_search_to_find("king") do |json|
      metadata = json['meta']
      expect(metadata).to have_key('current_page').with_value(1)
      expect(metadata).to have_key('next_page').with_value(nil)
      expect(metadata).to have_key('query').with_value("term" => "king")
      expect(json).to have_key('notices')
    end
  end

  context "facets" do
    scenario "returns facet information", js: true, search: true do
      notice = create(:notice, :with_facet_data, title: "The Lion King")

      expect_api_search_to_find("king") do |json|
        facets = json['meta']['facets']
        expect(facets.keys).to include(
          'sender_name', 'recipient_name', 'categories', 'date_received'
        )
      end
    end

    scenario "return facet query information", js: true, search: true do
      notice = create(:notice, :with_facet_data, title: "The Lion King")
      expect_api_search_to_find(
        "king", sender_name: notice.sender_name
      ) do |json|
        metadata = json['meta']
        expect(metadata).to have_key('query').with_value(
          "term" => "king",
          "sender_name" => notice.sender_name
        )
      end
    end
  end

  scenario "a notice has relevant metadata", js: true, search: true do
    category = create(:category, name: "Lion King")
    notice = create(
      :notice,
      categories: [category],
      title: "The Lion King on Youtube"
    )

    expect_api_search_to_find("king") do |json|
      json_item = json['notices'].first
      expect(json_item).to have_key('title').with_value(notice.title)
      expect(json_item).to have_key('id').with_value(notice.id)
      expect(json_item).to have_key('categories').with_value([category.name])
      expect(json_item).to have_key('score')
    end
  end

  def expect_api_search_to_find(term, options = {})
    sleep 1

    with_curb_get_for_json(
      "notices/search.json",
      options.merge(term: term)) do |curb|
      json = JSON.parse(curb.body_str)
      yield(json) if block_given?
    end
  end

end
