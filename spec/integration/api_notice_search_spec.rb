require 'rails_helper'

feature "Searching for Notices via the API" do
  include CurbHelpers
  include SearchHelpers

  scenario "the results array has relevant metadata", js: true, search: true do
    create(:dmca, title: "The Lion King on Youtube")
    index_changed_instances

    expect_api_search_to_find("king") do |json|
      metadata = json['meta']
      expect(metadata).to have_key('current_page').with_value(1)
      expect(metadata).to have_key('next_page').with_value(nil)
      expect(metadata).to have_key('query').with_value("term" => "king")
      expect(json).to have_key('notices')
    end

    50.times do |i|
      create(:dmca, title: "The Lion King on Youtube #{i}")
    end
    index_changed_instances

    expect_api_search_to_find("king", page: 3) do |json|
      metadata = json['meta']
      expect(metadata).to have_key('current_page').with_value(3)
      expect(metadata).to have_key('next_page').with_value(4)
      expect(metadata).to have_key('total_pages').with_value(6)
    end
  end

  context "facets" do
    scenario "returns facet information", js: true, search: true do
      create(:dmca, :with_facet_data, title: "The Lion King")
      index_changed_instances

      expect_api_search_to_find("king") do |json|
        facets = json['meta']['facets']
        expect(facets.keys).to include(
          'sender_name_facet',
          'principal_name_facet',
          'recipient_name_facet',
          'submitter_name_facet',
          'submitter_country_code_facet',
          'topic_facet',
          'date_received_facet'
        )
      end
    end

    scenario "return facet query information", js: true, search: true do
      notice = create(:dmca, :with_facet_data, title: "The Lion King")
      index_changed_instances

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

    scenario "return nothing for non-visible notices", js: true, search: true do
      options = Notice.visible_qualifiers.inject(title: "The Lion King") do |m, (k, v)|
        m.merge(k => !v)
      end
      notice = create(:dmca, :with_facet_data, options)
      index_changed_instances

      expect_api_search_to_find(
        "king", sender_name_facet: notice.sender_name
      ) do |json|
        results = {
          notices: json["notices"],
          normal_facets: json["meta"]["facets"].except("date_received_facet").collect { |k, v| v["buckets"].length }.max,
          range_facets: json["meta"]["facets"]["date_received_facet"]["buckets"].collect { |h| h["doc_count"] }.max
        }

        expect(results).to eq(notices: [], normal_facets: 0, range_facets: 0)
      end
    end
  end

  context 'sorting' do
    scenario "by date_received", js: true, search: true do
      notice = create(:dmca, title: 'Foobar First', date_received: Time.now)
      older_notice = create(
        :dmca, title: 'Foobar Last', date_received: Time.now - 10.days
      )
      index_changed_instances

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
      index_changed_instances

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

  (Notice.type_models - [Placeholder]).each do |klass|
    class_factory = klass.to_s.tableize.singularize.to_sym
    scenario "a #{klass} notice has basic notice metadata", js: true, search: true do

      topic = create(:topic, name: "Lion King")
      notice = create(
        class_factory,
        topics: [topic],
        title: "The Lion King on Youtube"
      )
      index_changed_instances
      expected_topics = [topic.name, Lumen::TYPES_TO_TOPICS[notice.type]].sort

      expect_api_search_to_find("king") do |json|
        json_item = json['notices'].first

        expect(json_item).to have_key('title').with_value(notice.title)
        expect(json_item).to have_key('id').with_value(notice.id)
        expect(json_item).to have_key('topics').with_value(expected_topics)
        expect(json_item).to have_key('score')
        expect(json_item).to have_key('tags')
      end
    end
  end

  context Trademark do
    scenario "has model-specific metadata", js: true, search: true do
      params = trademark_params(true)
      notice = Notice.new(params[:notice])
      notice.save

      index_changed_instances

      marks = notice.works.map do |work|
        {
          'description' => work.description,
          'infringing_urls' => work.infringing_urls_counted_by_fqdn.as_json
        }
      end

      expect_api_search_to_find("king") do |json|
        json_item = json['notices'].first
        expect(json_item).to have_key('marks')
        # We can't just compare json_item['marks'] to marks, because the
        # infringing_urls arrays may be in different orders, causing the
        # comparison to fail.
        expect(json_item['marks'].length).to eq(1)
        expect(json_item['marks'].first.keys.sort).to eq(marks.first.keys.sort)
        expect(json_item['marks'].first['description']
              ).to eq(marks.first['description'])
        expect(json_item['marks'].first['infringing_urls'].sort
              ).to eq(marks.first['infringing_urls'].sort)
        expect(json_item).to have_key('mark_registration_number').with_value('1337')
      end

      marks = notice.works.map do |work|
        {
          'description' => work.description,
          'infringing_urls' => work.infringing_urls.map(&:url)
        }
      end

      user = create(:user, :researcher)

      expect_api_search_to_find("king", { authentication_token: user.authentication_token }) do |json|
        json_item = json['notices'].first
        expect(json_item).to have_key('marks').with_value(marks)
        expect(json_item).not_to have_key('works')
        expect(json_item).to have_key('mark_registration_number').with_value('1337')
      end

      # Check if authorized users get full notice urls
      notice.destroy!
      params = trademark_params(true)
      notice = Notice.new(params[:notice])
      notice.save
      index_changed_instances

      user = create(:user, :researcher)

      marks = notice.works.map do |work|
        {
          'description' => work.description,
          'infringing_urls' => work.infringing_urls.map(&:url)
        }
      end

      expect_api_search_to_find('king', authentication_token: user.authentication_token) do |json|
        json_item = json['notices'].first
        expect(
          json_item['marks'].first['infringing_urls'].sort
        ).to eq(
          marks.first['infringing_urls'].sort
        )
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
      index_changed_instances

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

  context DataProtection do
    scenario "has model-specific metadata", js: true, search: true do
      create(
        :data_protection,
        title: "The Lion King on Youtube",
        body: "A test body"
      )
      index_changed_instances

      expect_api_search_to_find("king") do |json|
        json_item = json['notices'].first
        work = json_item['works'].first

        expect(json_item).to have_key('legal_complaint')
        expect(json_item).not_to have_key('body')

        expect(work).to have_key('urls_mentioned_in_request')
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
      index_changed_instances

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
      index_changed_instances

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
      index_changed_instances

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
      index_changed_instances

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

  context 'Sensitive notices available only for researchers' do
    scenario 'returns the full notice version of a researchers-only notice for a researcher user', js: true, search: true do
      params = trademark_params(true)
      notice = Notice.new(params[:notice])
      notice.save
      notice.submitter.full_notice_only_researchers = true
      notice.save
      index_changed_instances

      user = create(:user, :researcher)

      marks = notice.works.map do |work|
        {
          'description' => work.description,
          'infringing_urls' => work.infringing_urls.map(&:url)
        }
      end

      expect_api_search_to_find('king', authentication_token: user.authentication_token) do |json|
        json_item = json['notices'].first
        expect(
          json_item['marks'].first['infringing_urls'].sort
        ).to eq(
          marks.first['infringing_urls'].sort
        )
      end
    end

    scenario 'returns the limited notice version of a researchers-only notice for a researcher user not included in the allowed researchers list', js: true, search: true do
      params = trademark_params(true)
      user = create(:user, :researcher)
      user_allowed = create(:user, :researcher)
      notice = Notice.new(params[:notice])
      notice.save
      notice.submitter.full_notice_only_researchers = true
      notice.submitter.full_notice_only_researchers_users << user_allowed
      notice.submitter.full_notice_only_researchers_users << user
      notice.submitter.save
      index_changed_instances

      marks = notice.works.map do |work|
        {
          'description' => work.description,
          'infringing_urls' => work.infringing_urls.map(&:url)
        }
      end

      expect_api_search_to_find('king', authentication_token: user.authentication_token) do |json|
        json_item = json['notices'].first
        expect(
          json_item['marks'].first['infringing_urls'].sort
        ).to eq(
          marks.first['infringing_urls'].sort
        )
      end
    end

    scenario 'returns the full notice version of a researchers-only notice for a researcher user included in the allowed researchers list', js: true, search: true do
      params = trademark_params(true)
      user = create(:user, :researcher)
      user_allowed = create(:user, :researcher)
      notice = Notice.new(params[:notice])
      notice.save
      notice.submitter.full_notice_only_researchers = true
      notice.submitter.full_notice_only_researchers_users << user_allowed
      notice.submitter.save
      index_changed_instances

      marks = notice.works.map do |work|
        {
          'description' => work.description,
          'infringing_urls' => work.infringing_urls_counted_by_fqdn.as_json
        }
      end

      expect_api_search_to_find('king', authentication_token: user.authentication_token) do |json|\
        json_item = json['notices'].first
        expect(json_item).to have_key('marks')
        expect(json_item['marks'].length).to eq(1)
        expect(json_item['marks'].first.keys.sort).to eq(marks.first.keys.sort)
        expect(json_item['marks'].first['description']).to eq(marks.first['description'])
        expect(json_item['marks'].first['infringing_urls'].sort).to eq(marks.first['infringing_urls'].sort)
      end
    end
  end

  context 'Searching by date_submitted' do
    scenario 'returns notices submitted on a specific date range', js: true, search: true do
      notice = create(:dmca, title: 'Foobar')
      older_notice = create(:dmca, title: 'Foobar')
      older_notice.update_column(:created_at, Time.now - 10.days)

      index_changed_instances

      expect_api_search_to_find('Foobar', date_submitted: "#{notice.created_at.to_i - 60.seconds}000..#{notice.created_at.to_i + 60.seconds}000") do |json|
        expect(json['notices'].length).to eq(1)
        expect(json['notices'].first['id']).to eq(notice.id)
      end

      expect_api_search_to_find('Foobar', date_submitted: "#{notice.created_at.to_i - 10.days - 60.seconds}000..#{notice.created_at.to_i - 10.days + 60.seconds}000") do |json|
        expect(json['notices'].length).to eq(1)
        expect(json['notices'].first['id']).to eq(older_notice.id)
      end

      expect_api_search_to_find('Foobar', date_submitted: "#{notice.created_at.to_i - 10.days - 60.seconds}000..#{notice.created_at.to_i + 60.seconds}000") do |json|
        expect(json['notices'].length).to eq(2)
        expect(json['notices'].first['id']).to eq(notice.id)
        expect(json['notices'].last['id']).to eq(older_notice.id)
      end
    end
  end

  def expect_api_search_to_find(term, options = {})
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

  def trademark_params(with_full_urls)
    urls = if with_full_urls
             [
               { url: 'http://youtube.com/bad_url_3' },
               { url: 'http://youtube.com/bad_url_2' },
               { url: 'http://youtube.com/bad_url_1' }
             ]
           else
             [
               { domain: 'youtube.com', count: 3 }
             ]
           end

    {
      notice: {
        title: 'A title',
        type: 'Trademark',
        subject: 'Lion King Trademark Notification',
        date_sent: '2013-05-22',
        date_received: '2013-05-23',
        mark_registration_number: '1337',
        works_attributes: [
          {
            description: 'The Lion King on YouTube',
            infringing_urls_attributes: urls
          }
        ],
        entity_notice_roles_attributes: [
          {
            name: 'recipient',
            entity_attributes: {
              name: 'Google',
              kind: 'organization',
              address_line_1: '1600 Amphitheatre Parkway',
              city: 'Mountain View',
              state: 'CA',
              zip: '94043',
              country_code: 'US'
            }
          },
          {
            name: 'sender',
            entity_attributes: {
              name: 'Joe Lawyer',
              kind: 'individual',
              address_line_1: '1234 Anystreet St.',
              city: 'Anytown',
              state: 'CA',
              zip: '94044',
              country_code: 'US'
            }
          },
          {
            name: 'submitter',
            entity_attributes: {
              name: 'Joe Lawyer',
              kind: 'individual',
              address_line_1: '1234 Anystreet St.',
              city: 'Anytown',
              state: 'CA',
              zip: '94044',
              country_code: 'US'
            }
          }
        ]
      }
    }
  end
end
