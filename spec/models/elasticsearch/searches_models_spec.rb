require 'spec_helper'

# This model test primarily checks that SearchesModels produces a correctly
# formed Elasticsearch query, given various inputs. It doesn't check that good
# results get returned (that's up to Elasticsearch) or displayed (integration
# tests).
# Separating #prepare from #search in SearchesModels gives us a seam that lets
# us test here, checking the prepared query without needing to mock out
# Elasticsearch. Additionally, checking the query will simplify upgrading to
# other versions of Elasticsearch in future; when the query DSL changes, we
# can first update the tests here to assert that we produce the correct query
# syntax, and then update SearchesModels until tests pass.
describe SearchesModels, type: :model do
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
