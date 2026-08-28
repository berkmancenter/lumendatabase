require 'spec_helper'

# This model test primarily checks that Lumen::Search::Query produces a correctly
# formed Elasticsearch query, given various inputs. It doesn't check that good
# results get returned (that's up to Elasticsearch) or displayed (integration
# tests).
# Separating #prepare from #search in Lumen::Search::Query gives us a seam that lets
# us test here, checking the prepared query without needing to mock out
# Elasticsearch. Additionally, checking the query will simplify upgrading to
# other versions of Elasticsearch in future; when the query DSL changes, we
# can first update the tests here to assert that we produce the correct query
# syntax, and then update Lumen::Search::Query until tests pass.
describe Lumen::Search::Query, type: :model do

  # This test has the expected query syntax for a query that exercises many
  # searching/filtering/aggregating/highlighting functions. When updating ES
  # versions, we can update the `expected` variable to the new syntax, and then
  # update the model until it matches.
  it 'produces a correct query' do
    now = Time.now.beginning_of_day
    day_ago = now - 1.day
    month_ago = now - 1.month
    six_months_ago = now - 6.months
    year_ago = now - 12.months

    # Important to specify timezone, because otherwise it may not be the same
    # as the epoch-denominated times below.
    end_of_date_range = Time.new(2020, 5, 21, 0, 0, 0, '-04:00').beginning_of_day
    beginning_of_date_range = end_of_date_range - 1.year


    expected = {
      _source: ["score", "id", "title"],
      query: {
        bool: {
          must: [
            { match: { spam: { query: false, operator: 'AND' } } },
            { match: { hidden: { query: false, operator: 'AND' } } },
            { match: { published: { query: true, operator: 'AND' } } },
            { match: { rescinded: { query: false, operator: 'AND' } } },
            { multi_match: {
              query: 'i give up',
              fields: Notice::MULTI_MATCH_FIELDS,
              type: :cross_fields,
              operator: 'AND',
              analyzer: Notice::UNQUOTED_SEARCH_ANALYZER
            } }
          ],
          filter: [
            { term: { sender_name_facet: 'Mike Itten' } },
            { range: {
                date_received: {
                  from: beginning_of_date_range,
                  to: end_of_date_range
                }
              }
            }
          ]
        }
      },
      aggregations: {
        topic_facet: { terms: { field: :topic_facet } },
        sender_name_facet: { terms: { field: :sender_name_facet } },
        principal_name_facet: { terms: { field: :principal_name_facet } },
        recipient_name_facet: { terms: { field: :recipient_name_facet } },
        submitter_name_facet: { terms: { field: :submitter_name_facet } },
        tag_list_facet: { terms: { field: :tag_list_facet } },
        country_code_facet: { terms: { field: :country_code_facet } },
        language_facet: { terms: { field: :language_facet } },
        submitter_country_code_facet: { terms:
          { field: :submitter_country_code_facet}
        },
        action_taken_facet: { terms: { field: :action_taken_facet } },
        date_received_facet: {
          date_range: {
            field: :date_received_facet,
            ranges: [
              { from: day_ago, to: now },
              { from: month_ago, to: now },
              { from: six_months_ago, to: now },
              { from: year_ago, to: now }
            ]
          }
        }
      },
      highlight: {
        pre_tags: '<em>',
        post_tags: '</em>',
        type: 'plain',
        require_field_match: false,
        max_analyzed_offset: 999_999,
        fields: {
          :base_search=>{},
          :preferred_search=>{}
        }
      },
      size: 10,
      from: 0
    }

    params = {
      "sender_name_facet"=>"Mike Itten",
      "date_received_facet"=>"1558411200000.0..1590033600000.0",
      "term"=>"i give up",
      "term-require-all"=>"true"
    }

    es_query = Lumen::Search::Query.new(params).tap do |searcher|
      Notice::SEARCHABLE_FIELDS.each do |searched_field|
        searcher.register searched_field
      end

      Notice::FILTERABLE_FIELDS.each do |filtered_field|
        searcher.register filtered_field
      end
    end
    es_query.prepare

    expect(es_query.search_definition).to eq expected
  end

  context 'misc functions' do
    it 'returns an elasticsearch search instance', vcr: true do
      expect(subject.search).to be_instance_of(Elasticsearch::Model::Response::Response)
    end

    it 'allows searches / filters to be registered' do
      title_filter = Lumen::Search::TermFilter.new(:title)
      date_range_filter = Lumen::Search::DateRangeFilter.new('1590009037000..1590009039000')
      unspecified_filter = Lumen::Search::UnspecifiedTermFilter.new(:batman)
      search = Lumen::Search::TermSearch.new(:title, :batman)

      subject.register title_filter
      subject.register date_range_filter
      subject.register unspecified_filter
      subject.register search

      expect(subject.registry[:filters]).to include title_filter
      expect(subject.registry[:filters]).to include date_range_filter
      expect(subject.registry[:filters]).to include unspecified_filter
      expect(subject.registry[:searches]).to include search
    end

    it "limits the search to the model's visible_qualifiers" do
      obj = described_class.new

      obj.prepare
      must = obj.search_definition[:query][:bool][:must]

      expect(obj.model_class).to eq Notice  # check assumption
      # Notice.visible_qualifiers:
      # { spam: false, hidden: false, published: true, rescinded: false }
      expect(must).to include( { match: { spam: { query: false, operator: "AND" } } } )
      expect(must).to include( { match: { hidden: { query: false, operator: "AND" } } } )
      expect(must).to include( { match: { published: { query: true, operator: "AND" } } } )
      expect(must).to include( { match: { rescinded: { query: false, operator: "AND" } } } )
    end

    it 'can restrict results to notices with matching enterprise domains' do
      obj = described_class.new

      obj.restrict_to_enterprise_domains(['Example.com'])
      obj.prepare

      expect(obj.search_definition[:query][:bool][:filter]).to include(
        bool: {
          should: [
            { match_phrase: { 'works.infringing_urls.url': 'example.com' } }
          ],
          minimum_should_match: 1
        }
      )
    end

    it 'fails closed when enterprise domain restriction has no domains' do
      obj = described_class.new

      obj.restrict_to_enterprise_domains([])
      obj.prepare

      expect(obj.search_definition[:query][:bool][:filter]).to include(
        term: { id: '__no_enterprise_domains__' }
      )
    end
  end

  context 'faceting searches' do
    Notice::FILTERABLE_FIELDS.each do |filter|
      next if filter.is_a? Lumen::Search::DateRangeFilter  # they have weird syntax

      it "respects #{filter.parameter}" do
        obj = described_class.new(filter.parameter => 'batman')
        obj.register filter

        obj.prepare

        expect(obj.search_definition[:query][:bool][:filter]).to include(
          { term: { filter.parameter => 'batman' } }
        )
      end
    end

    it 'respect date ranges' do
      filter = Lumen::Search::DateRangeFilter.new(:date_received_facet, :date_received, 'Date')
      obj = described_class.new(date_received_facet: '1589830316000..1589916716000')
      obj.register filter

      obj.prepare

      expect(obj.search_definition[:query][:bool][:filter]).to include(
        { range: { date_received: {
          from: '2020-05-18 15:31:56.000000000 -0400',
          to: '2020-05-19 15:31:56.000000000 -0400'
        } } }
      )
    end
  end

  context 'searching by field' do
    Notice::SEARCHABLE_FIELDS.each do |search|
      case search.field
      when Array
        it "respects #{search.parameter}" do
          obj = described_class.new(search.parameter => 'batman')
          obj.register search

          obj.prepare

          expected_query = {
            query: 'batman',
            fields: search.field.map(&:to_s),
            operator: 'OR'
          }
          if search.parameter == :term
            expected_query[:analyzer] = Notice::UNQUOTED_SEARCH_ANALYZER
          end

          expect(obj.search_definition[:query][:bool][:must]).to include(
            multi_match: expected_query
          )
        end

        it "matches all when required for #{search.parameter}" do
          obj = described_class.new(
            search.parameter => 'all of these',
            "#{search.parameter}-require-all" => true
          )
          obj.register search

          obj.prepare

          expected_query = {
            query: 'all of these',
            fields: search.field.map(&:to_s),
            operator: 'AND',
            # The 'AND' operator doesn't work the way you expect on the
            # default multi_match type. See
            # https://www.elastic.co/guide/en/elasticsearch/reference/6.8/query-dsl-multi-match-query.html .
            type: :cross_fields
          }
          if search.parameter == :term
            expected_query[:analyzer] = Notice::UNQUOTED_SEARCH_ANALYZER
          end

          expect(obj.search_definition[:query][:bool][:must]).to include(
            multi_match: expected_query
          )
        end
      else
        it "respects #{search.parameter}" do
          obj = described_class.new(search.parameter => 'batman')
          obj.register search

          obj.prepare

          expect(obj.search_definition[:query][:bool][:must]).to include(
            { match: { search.field => { query: 'batman', operator: 'OR'} } }
          )
        end

        it "matches all when required for #{search.parameter}" do
          obj = described_class.new(
            search.parameter => 'all of these',
            "#{search.parameter}-require-all" => true
          )
          obj.register search

          obj.prepare

          expect(obj.search_definition[:query][:bool][:must]).to include(
            { match: { search.field => { query: 'all of these', operator: 'AND'} } }
          )
        end
      end
    end
  end

  context 'progressive matching for global searches' do
    let(:global_search) { Notice::SEARCHABLE_FIELDS.first }

    it 'keeps short unquoted searches on the existing match-any behavior' do
      term = 'one two three four'
      obj = described_class.new('term' => term)
      obj.register global_search

      obj.prepare

      expect(obj.search_definition[:query][:bool][:must]).to include(
        multi_match: {
          query: term,
          fields: Notice::MULTI_MATCH_FIELDS,
          operator: 'OR',
          analyzer: Notice::UNQUOTED_SEARCH_ANALYZER
        }
      )
    end

    it 'progressively requires more matches for unquoted searches of five or more words' do
      term = 'one two three four five'
      obj = described_class.new('term' => term)
      obj.register global_search

      obj.prepare

      expect(obj.search_definition[:query][:bool][:must]).to include(
        multi_match: {
          query: term,
          fields: Notice::MULTI_MATCH_FIELDS,
          operator: 'OR',
          minimum_should_match: described_class::PROGRESSIVE_TERM_MINIMUM_SHOULD_MATCH,
          analyzer: Notice::UNQUOTED_SEARCH_ANALYZER,
          type: :cross_fields
        }
      )
    end

    it 'does not change explicit all-words searches' do
      term = 'one two three four five'
      obj = described_class.new('term' => term, 'term-require-all' => true)
      obj.register global_search

      obj.prepare

      expect(obj.search_definition[:query][:bool][:must]).to include(
        multi_match: {
          query: term,
          fields: Notice::MULTI_MATCH_FIELDS,
          operator: 'AND',
          analyzer: Notice::UNQUOTED_SEARCH_ANALYZER,
          type: :cross_fields
        }
      )
    end

    it 'does not change field-specific searches' do
      term = 'one two three four five'
      title_search = Notice::SEARCHABLE_FIELDS.find { |search| search.parameter == :title }
      obj = described_class.new('title' => term)
      obj.register title_search

      obj.prepare

      expect(obj.search_definition[:query][:bool][:must]).to include(
        match: {
          title: {
            query: term,
            operator: 'OR'
          }
        }
      )
    end

    it 'does not change quoted phrase searches' do
      term = '"one two three four five"'
      obj = described_class.new('term' => term)
      obj.register global_search

      obj.prepare

      expect(obj.search_definition[:query][:bool][:must]).to include(
        multi_match: {
          query: term,
          fields: Notice::MULTI_MATCH_FIELDS,
          operator: 'OR',
          type: :phrase
        }
      )
    end

    it 'does not change multi-label bare domain searches' do
      term = 'one.two.three.example.com'
      obj = described_class.new('term' => term)
      obj.register global_search

      obj.prepare

      expect(obj.search_definition[:query][:bool][:must]).to include(
        multi_match: {
          query: term,
          fields: Notice::MULTI_MATCH_FIELDS,
          operator: 'OR'
        }
      )
    end

    it 'does not change searches containing numeric identifiers' do
      term = 'Entity name 51'
      obj = described_class.new('term' => term)
      obj.register global_search

      obj.prepare

      expect(obj.search_definition[:query][:bool][:must]).to include(
        multi_match: {
          query: term,
          fields: Notice::MULTI_MATCH_FIELDS,
          operator: 'OR'
        }
      )
    end
  end

  context 'exact searching' do
    it 'automatically searches an unquoted full URL as an exact URL' do
      term = 'https://imgur.com/a/rge778&dew87'
      obj = described_class.new('term' => term)
      obj.register Notice::SEARCHABLE_FIELDS.first

      obj.prepare

      expect(obj.search_definition[:query][:bool][:must]).to include(
        multi_match: {
          query: term,
          fields: Notice::EXACT_URL_SEARCH_FIELDS,
          operator: 'OR',
          type: :phrase
        }
      )
      expect(obj.search_definition[:highlight]).to include(
        highlight_query: {
          multi_match: {
            query: term,
            fields: Notice::MULTI_MATCH_FIELDS,
            operator: 'OR',
            type: :phrase
          }
        }
      )
    end

    it 'automatically searches an unquoted www hostname as an exact domain' do
      term = 'www.youtube.com'
      obj = described_class.new('term' => term)
      obj.register Notice::SEARCHABLE_FIELDS.first

      obj.prepare

      expect(obj.search_definition[:query][:bool][:must]).to include(
        multi_match: {
          query: term,
          fields: Notice::EXACT_URL_SEARCH_FIELDS,
          operator: 'OR',
          type: :phrase
        }
      )
    end

    it 'keeps an unquoted bare domain on the catch-all fields' do
      term = 'youtube.com'
      obj = described_class.new('term' => term)
      obj.register Notice::SEARCHABLE_FIELDS.first

      obj.prepare

      expect(obj.search_definition[:query][:bool][:must]).to include(
        multi_match: {
          query: term,
          fields: Notice::MULTI_MATCH_FIELDS,
          operator: 'OR'
        }
      )
    end

    it 'keeps an unquoted arbitrary subdomain on the catch-all fields' do
      term = 'r2.cloudflarestorage.com'
      obj = described_class.new('term' => term)
      obj.register Notice::SEARCHABLE_FIELDS.first

      obj.prepare

      expect(obj.search_definition[:query][:bool][:must]).to include(
        multi_match: {
          query: term,
          fields: Notice::MULTI_MATCH_FIELDS,
          operator: 'OR'
        }
      )
    end

    it 'keeps an incomplete URL on the catch-all fields' do
      term = 'https://'
      obj = described_class.new('term' => term)
      obj.register Notice::SEARCHABLE_FIELDS.first

      obj.prepare

      expect(obj.search_definition[:query][:bool][:must]).to include(
        multi_match: {
          query: term,
          fields: Notice::MULTI_MATCH_FIELDS,
          operator: 'OR'
        }
      )
      expect(obj.search_definition[:highlight]).not_to have_key(:highlight_query)
    end

    it 'searches source fields for a full URL or registrable domain' do
      exact_searches = [
        '"http://vextro.k7f2d9a4c1b8e6350f4a9d2c7e1b6a3f.r2.cloudflarestorage.com"',
        '"cloudflarestorage.com"'
      ]

      exact_searches.each do |term|
        obj = described_class.new('term' => term)
        obj.register Notice::SEARCHABLE_FIELDS.first

        obj.prepare

        expect(obj.search_definition[:query][:bool][:must]).to include(
          multi_match: {
            query: term,
            fields: Notice::EXACT_URL_SEARCH_FIELDS,
            operator: 'OR',
            type: :phrase
          }
        )
        expect(obj.search_definition[:highlight]).to include(
          highlight_query: {
            multi_match: {
              query: term,
              fields: Notice::MULTI_MATCH_FIELDS,
              operator: 'OR',
              type: :phrase
            }
          }
        )
      end
    end

    it 'also searches catch-all fields for an exact subdomain suffix' do
      term = '"r2.cloudflarestorage.com"'
      obj = described_class.new('term' => term)
      obj.register Notice::SEARCHABLE_FIELDS.first

      obj.prepare

      expect(obj.search_definition[:query][:bool][:must]).to include(
        bool: {
          should: [
            {
              multi_match: {
                query: term,
                fields: Notice::EXACT_URL_SEARCH_FIELDS,
                operator: 'OR',
                type: :phrase
              }
            },
            {
              multi_match: {
                query: term,
                fields: Notice::MULTI_MATCH_FIELDS,
                operator: 'OR',
                type: :phrase
              }
            }
          ],
          minimum_should_match: 1
        }
      )
    end

    it 'keeps URL fragments on the catch-all fields' do
      exact_searches = [
        '"vextro.k7f2d9a4c1b8e6350f4a9d2c7e1b6a3f"',
        '"k7f2d9a4c1b8e6350f4a9d2c7e1b6a3f.r2"'
      ]

      exact_searches.each do |term|
        obj = described_class.new('term' => term)
        obj.register Notice::SEARCHABLE_FIELDS.first

        obj.prepare

        expect(obj.search_definition[:query][:bool][:must]).to include(
          multi_match: {
            query: term,
            fields: Notice::MULTI_MATCH_FIELDS,
            operator: 'OR',
            type: :phrase
          }
        )
        expect(obj.search_definition[:highlight]).not_to have_key(:highlight_query)
      end
    end
  end

  context '.cache_key' do
    it 'is the same for different instances of the same search' do
      params = { utf8: '✓', term: 'lion', sort_by: '',
                 controller: 'notices/search', action: 'index' }

      searcher1 = described_class.new(params)
      searcher2 = described_class.new(params)

      expect(searcher1.cache_key).to eq searcher2.cache_key
    end

    it 'is different for different pages of the same search' do
      params = { utf8: '✓', term: 'lion', sort_by: '',
                 controller: 'notices/search', action: 'index' }
      params2 = params.dup
      params2[:page] = '2'

      searcher_page1 = described_class.new(params)

      searcher_page2 = described_class.new(params2)

      expect(searcher_page1.cache_key).not_to eq searcher_page2.cache_key
    end

    it 'is different when the same value is used for different fields' do
      term_searcher = described_class.new(term: 'lion')
      title_searcher = described_class.new(title: 'lion')

      expect(term_searcher.cache_key).not_to eq title_searcher.cache_key
    end

    it 'is stable when parameters have a different insertion order' do
      searcher1 = described_class.new(term: 'lion', page: '2')
      searcher2 = described_class.new(page: '2', term: 'lion')

      expect(searcher1.cache_key).to eq searcher2.cache_key
    end

    it 'is different for different searched models' do
      notice_searcher = described_class.new({ term: 'lion' }, Notice)
      entity_searcher = described_class.new({ term: 'lion' }, Entity)

      expect(notice_searcher.cache_key).not_to eq entity_searcher.cache_key
    end

    it 'is different for search interfaces rendering different fragments' do
      public_searcher = described_class.new(term: 'lion', controller: 'notices/search')
      enterprise_searcher = described_class.new(term: 'lion', controller: 'enterprise/notices/search')

      expect(public_searcher.cache_key).not_to eq enterprise_searcher.cache_key
    end

    it 'is different for enterprise domain restrictions' do
      params = { utf8: '✓', term: 'lion', sort_by: '',
                 controller: 'notices/search', action: 'index' }

      searcher1 = described_class.new(params)
      searcher1.restrict_to_enterprise_domains(['example.com'])

      searcher2 = described_class.new(params)
      searcher2.restrict_to_enterprise_domains(['example.org'])

      expect(searcher1.cache_key).not_to eq searcher2.cache_key
    end
  end
end
