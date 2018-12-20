require 'spec_helper'

describe SearchesModels, type: :model, vcr: true do
  context 'visible_qualifiers' do
    it 'delegates to the @model_class' do
      expected = { expected_key: :expected_value }
      allow(FakeModel).to receive(:visible_qualifiers).and_return(expected)
      expect(described_class.new({}, FakeModel).visible_qualifiers).to eq(expected)
    end

    it 'fills in if @model_class does not support it' do
      expect(described_class.new({}, FakeModel).visible_qualifiers).to eq({})
    end

    it 'has a real value calling with all defaults' do
      expected = { spam: false, hidden: false, published: true, rescinded: false }
      expect(described_class.new.visible_qualifiers).to eq(expected)
    end
  end

  it 'returns an elasticsearch search instance' do
    expect(subject.search).to be_instance_of(Elasticsearch::Model::Response::Response)
  end

  it 'finds the index_name from the model_class' do
    expect(FakeModel.index_name).to eq('fake_models')

    FakeModel.__elasticsearch__.create_index! force: true
    searcher = described_class.new({ foo: 'bar' }, FakeModel)
    searcher.search
  end

  it 'allows searches / filters to be registered' do
    title_filter = TermFilter.new(:title)

    subject.register title_filter

    expect(subject.registry.first).to eq title_filter
  end

  context 'filters' do
    it 'correctly configures facets' do
      subject.register TermFilter.new(:sender_name_facet)
      expect(subject.search.aggregations[:sender_name_facet]).to be
    end

    it 'asks for the filter' do
      filter = TermFilter.new(:sender_name_facet)
      searcher = described_class.new(params_hash)
      searcher.register filter

      expect(filter).to receive(:filter_for).with(params_hash[:sender_name_facet]).and_return(
        [bleep: { foo: ['as'] }]
      )
      searcher.search
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

  context 'searches' do
    it 'dispatches to a registered term search' do
      all_fields = TermSearch.new(:term, :_all)
      searcher = described_class.new(params_hash)
      searcher.register all_fields

      expect(all_fields).to receive(:query_for).with(params_hash[:term], nil).and_call_original

      searcher.search
    end

    it 'dispatches with an operator' do
      all_fields = TermSearch.new(:term, :_all)
      modified_params_hash = params_hash.merge('term-require-all' => true)
      searcher = described_class.new(modified_params_hash)
      searcher.register all_fields

      expect(all_fields).to receive(:query_for).with(params_hash[:term], 'AND').and_call_original
      searcher.search
    end
  end
end

class FakeModel
  include Elasticsearch::Model
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  PER_PAGE = 10
  HIGHLIGHTS = %i[foo bar].freeze
end

def params_hash
  {
    term: 'foo',
    sender_name_facet: 'Sender name'
  }
end
