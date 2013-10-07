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
          'sender_name_facet',
          'principal_name_facet',
          'recipient_name_facet',
          'topic_facet',
          'date_received_facet'
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

  context 'sorting' do
    scenario "by date_received", js: true, search: true do
      notice = create(:dmca, title: 'Foobar First', date_received: Time.now)
      older_notice = create(
        :dmca, title: 'Foobar Last', date_received: Time.now - 10.days
      )

      expect_api_search_to_find("Foobar", sort_by: "date_received asc") do |json|
        expect(first_notice_id(json)).to be(older_notice.id)
        expect(last_notice_id(json)).to be(notice.id)
      end

      expect_api_search_to_find("Foobar", sort_by: "date_received desc") do |json|
        expect(first_notice_id(json)).to be(notice.id)
        expect(last_notice_id(json)).to be(older_notice.id)
      end
    end

    scenario "by relevancy", js: true, search: true do
      notice = create(:dmca, title: 'Foobar Foobar First')
      less_relevant_notice = create(:dmca, title: 'Foobar Last')

      expect_api_search_to_find("Foobar", sort_by: "relevancy asc") do |json|
        expect(first_notice_id(json)).to be(less_relevant_notice.id)
        expect(last_notice_id(json)).to be(notice.id)
      end

      expect_api_search_to_find("Foobar", sort_by: "relevancy desc") do |json|
        expect(first_notice_id(json)).to be(notice.id)
        expect(last_notice_id(json)).to be(less_relevant_notice.id)
      end
    end
  end

  Notice.type_models.each do |klass|
    class_factory = klass.to_s.tableize.singularize.to_sym
    scenario "a #{klass} notice has basic notice metadata", js: true, search: true do

      topic = create(:topic, name: "Lion King")
      notice = create(
        class_factory,
        topics: [topic],
        title: "The Lion King on Youtube"
      )

      expect_api_search_to_find("king") do |json|
        json_item = json['notices'].first
        expect(json_item).to have_key('title').with_value(notice.title)
        expect(json_item).to have_key('id').with_value(notice.id)
        expect(json_item).to have_key('topics').with_value([topic.name])
        expect(json_item).to have_key('score')
        expect(json_item).to have_key('tags')
      end
    end
  end

  context Trademark do
    scenario "has model-specific metadata", js: true, search: true do
      notice = create(
        :trademark,
        :with_facet_data,
        title: "The Lion King on Youtube",
        mark_registration_number: '1337'
      )

      marks = notice.works.collect{|work| work.description}

      expect_api_search_to_find("king") do |json|
        json_item = json['notices'].first
        expect(json_item).to have_key('marks').with_value(marks)
        expect(json_item).not_to have_key('works')
        expect(json_item).to have_key('mark_registration_number').with_value('1337')
      end
    end
  end

  context Defamation do
    scenario "has model-specific metadata", js: true, search: true do
      create(
        :defamation,
        title: "The Lion King on Youtube",
        body: "A test body"
      )

      expect_api_search_to_find("king") do |json|
        json_item = json['notices'].first
        work = json_item['works'].first

        expect(json_item).to have_key('legal_complaint')
        expect(json_item).not_to have_key('body')

        expect(work).to have_key('defamatory_urls')

        expect(work).not_to have_key('copyrighted_urls')
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

        expect(json_item['laws_referenced']).to match_array(
          ['Baz blee 22', 'Foo bar 21']
        )
        expect(json_item).to have_key('explanation')

        expect(work).to have_key('targetted_urls')
        expect(work).to have_key('subject_of_court_order')

        expect(work).not_to have_key('copyrighted_urls')
        expect(work).not_to have_key('description')
        expect(work).not_to have_key('body')
      end
    end
  end

  context LawEnforcementRequest do
    scenario "has model-specific metadata", js: true, search: true do
      create(
        :law_enforcement_request,
        title: "The Lion King on Youtube",
        regulation_list: 'Foo bar 21, Baz blee 22',
        request_type: 'Civil Subpoena',
      )

      expect_api_search_to_find("king") do |json|
        json_item = json['notices'].first
        work = json_item['works'].first

        expect(json_item['regulations']).to match_array(
          ['Baz blee 22', 'Foo bar 21']
        )
        expect(json_item).to have_key('explanation')
        expect(json_item).to have_key('request_type').
          with_value('Civil Subpoena')

        expect(work).to have_key('original_work_urls')
        expect(work).to have_key('urls_in_request')
        expect(work).to have_key('subject_of_enforcement_request')

        expect(work).not_to have_key('description')
        expect(work).not_to have_key('body')
      end
    end
  end

  context PrivateInformation do
    scenario "has model-specific metadata", js: true, search: true do
      create(
        :private_information,
        title: "The Lion King on Youtube",
      )

      expect_api_search_to_find("king") do |json|
        json_item = json['notices'].first
        work = json_item['works'].first

        expect(json_item).to have_key('explanation')
        expect(work).to have_key('urls_with_private_information')
        expect(work).to have_key('complaint')

        expect(work).not_to have_key('description')
        expect(work).not_to have_key('body')
        expect(json_item).not_to have_key('body')
      end
    end
  end

  context Other do
    scenario "has model-specific metadata", js: true, search: true do
      create(
        :other,
        title: "The Lion King on Youtube",
      )

      expect_api_search_to_find("king") do |json|
        json_item = json['notices'].first
        work = json_item['works'].first

        expect(json_item).to have_key('explanation')
        expect(work).to have_key('original_work_urls')
        expect(work).to have_key('problematic_urls')
        expect(work).to have_key('complaint')

        expect(work).not_to have_key('description')
        expect(work).not_to have_key('body')
        expect(json_item).not_to have_key('body')
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

  def first_notice_id(json)
    json['notices'].first['id']
  end

  def last_notice_id(json)
    json['notices'].last['id']
  end

end
