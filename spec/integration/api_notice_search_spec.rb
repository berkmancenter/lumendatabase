require 'spec_helper'

feature "Searching for Notices via the API" do
  include CurbHelpers

  scenario "the results array has relevant metadata", js: true, search: true do
    create(:dmca, title: "The Lion King on Youtube")
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
      create(:dmca, :with_facet_data, title: "The Lion King")

      expect_api_search_to_find("king") do |json|
        facets = json['meta']['facets']
        expect(facets.keys).to include(
          'sender_name_facet', 'recipient_name_facet', 'category_facet', 'date_received_facet'
        )
      end
    end

    scenario "return facet query information", js: true, search: true do
      notice = create(:dmca, :with_facet_data, title: "The Lion King")
      expect_api_search_to_find(
        "king", sender_name_facet: notice.sender_name
      ) do |json|
        metadata = json['meta']
        expect(metadata).to have_key('query').with_value(
          "term" => "king",
          "sender_name_facet" => notice.sender_name
        )
      end
    end
  end

  [Dmca, Trademark, Defamation, International, CourtOrder].each do |klass|
    class_factory = klass.to_s.tableize.singularize.to_sym
    scenario "a #{klass} notice has basic notice metadata", js: true, search: true do

      category = create(:category, name: "Lion King")
      notice = create(
        class_factory,
        categories: [category],
        title: "The Lion King on Youtube"
      )

      expect_api_search_to_find("king") do |json|
        json_item = json['notices'].first
        expect(json_item).to have_key('title').with_value(notice.title)
        expect(json_item).to have_key('id').with_value(notice.id)
        expect(json_item).to have_key('categories').with_value([category.name])
        expect(json_item).to have_key('score')
        expect(json_item).to have_key('tags')
      end
    end
  end

  context Trademark do
    scenario "has model-specific metadata", js: true, search: true do
      create(
        :trademark,
        title: "The Lion King on Youtube"
      )

      expect_api_search_to_find("king") do |json|
        json_item = json['notices'].first
        expect(json_item).to have_key('marks')
        expect(json_item).not_to have_key('works')
      end
    end
  end

  context Defamation do
    scenario "has model-specific metadata", js: true, search: true do
      create(
        :trademark,
        title: "The Lion King on Youtube"
      )

      expect_api_search_to_find("king") do |json|
        json_item = json['notices'].first
        expect(json_item).to have_key('marks')
        expect(json_item).not_to have_key('works')
      end
    end
  end

  context International do
    scenario "has model-specific metadata", js: true, search: true do
      create(
        :international,
        title: "The Lion King on Youtube",
        regulation_list: 'Foo bar 21, Baz blee 22'
      )

      expect_api_search_to_find("king") do |json|
        json_item = json['notices'].first
        work = json_item['works'].first

        expect(json_item).to have_key('regulations').
          with_value(['Baz blee 22', 'Foo bar 21'])
        expect(json_item).to have_key('explanation')
        expect(work).to have_key('original_work_urls')
        expect(work).to have_key('offending_urls')
        expect(work).to have_key('subject_of_complaint')

        expect(work).not_to have_key('description')
        expect(work).not_to have_key('body')
      end
    end
  end

  context CourtOrder do
    scenario "has model-specific metadata", js: true, search: true do
      create(
        :court_order,
        title: "The Lion King on Youtube",
        regulation_list: 'Foo bar 21, Baz blee 22'
      )

      # TODO - figure out what to do with additional entities.

      expect_api_search_to_find("king") do |json|
        json_item = json['notices'].first
        work = json_item['works'].first

        expect(json_item).to have_key('regulations').
          with_value(['Baz blee 22', 'Foo bar 21'])
        expect(json_item).to have_key('explanation')

        expect(work).to have_key('targetted_urls')
        expect(work).to have_key('subject_of_court_order')

        expect(work).not_to have_key('copyrighted_urls')
        expect(work).not_to have_key('description')
        expect(work).not_to have_key('body')
      end
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
