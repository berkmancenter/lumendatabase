require 'spec_helper'

# This model test primarily checks that ElasticsearchQuery produces a correctly
# formed Elasticsearch query, given various inputs. It doesn't check that good
# results get returned (that's up to Elasticsearch) or displayed (integration
# tests).
# Separating #prepare from #search in ElasticsearchQuery gives us a seam that lets
# us test here, checking the prepared query without needing to mock out
# Elasticsearch. Additionally, checking the query will simplify upgrading to
# other versions of Elasticsearch in future; when the query DSL changes, we
# can first update the tests here to assert that we produce the correct query
# syntax, and then update ElasticsearchQuery until tests pass.
describe ElasticsearchQuery, type: :model do

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

    end_of_date_range = Time.new(2020, 5, 21).beginning_of_day
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
              fields:  Searchability::MULTI_MATCH_FIELDS,
              type: :cross_fields,
              operator: 'AND'
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
        fields: {
          title: { type: 'plain', require_field_match: false },
          tag_list: { type: 'plain', require_field_match: false },
          :'topics.name' => { type: 'plain', require_field_match: false },
          sender_name: { type: 'plain', require_field_match: false },
          recipient_name: { type: 'plain', require_field_match: false },
          :'works.description' => { type: 'plain', require_field_match: false },
          :'works.infringing_urls.url' => { type: 'plain', require_field_match: false },
          :'works.copyrighted_urls.url' => { type: 'plain', require_field_match: false }
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

    es_query = ElasticsearchQuery.new(params).tap do |searcher|
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
      title_filter = TermFilter.new(:title)
      date_range_filter = DateRangeFilter.new('1590009037000..1590009039000')
      unspecified_filter = UnspecifiedTermFilter.new(:batman)
      search = TermSearch.new(:title, :batman)

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
  end

  context 'faceting searches' do
    Notice::FILTERABLE_FIELDS.each do |filter|
      next if filter.is_a? DateRangeFilter  # they have weird syntax

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
      filter = DateRangeFilter.new(:date_received_facet, :date_received, 'Date')
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

          expect(obj.search_definition[:query][:bool][:must]).to include(
            { multi_match: {
              query: 'batman',
              fields: search.field.map(&:to_s),
              operator: 'OR'
            } }
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
            { multi_match: {
              query: 'all of these',
              fields: search.field.map(&:to_s),
              operator: 'AND',
              # The 'AND' operator doesn't work the way you expect on the
              # default multi_match type. See
              # https://www.elastic.co/guide/en/elasticsearch/reference/6.8/query-dsl-multi-match-query.html .
              type: :cross_fields
            } }
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
  end
end
