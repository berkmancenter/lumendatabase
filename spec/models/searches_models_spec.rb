require 'spec_helper'

describe SearchesModels, type: :model do
  context 'visible_qualifiers' do
    it "delegates to the @model_class" do
      expected = { expected_key: :expected_value }
      allow(FakeModel).to receive(:visible_qualifiers).and_return(expected)
      expect(described_class.new({}, FakeModel).visible_qualifiers).to eq(expected)
    end

    it "fills in if @model_class does not support it" do
      expect(described_class.new({}, FakeModel).visible_qualifiers).to eq({})
    end

    it "has a real value calling with all defaults" do
      expected = { spam: false, hidden: false, published: true, rescinded: false }
      expect(described_class.new.visible_qualifiers).to eq(expected)
    end
  end

  it "returns an elasticsearch search instance" do
    expect(subject.search).to be_instance_of(Tire::Search::Search)
  end

  it "finds the index_name from the model_class" do
    expect(FakeModel).to receive(:index_name)

    searcher = described_class.new({foo: 'bar'}, FakeModel)
    searcher.search
  end

  it "allows searches / filters to be registered" do
    title_filter = TermFilter.new(:title)

    subject.register title_filter

    expect(subject.registry.first).to eq title_filter
  end

  context 'filters' do
    it "correctly configures facets" do
      subject.register TermFilter.new(:title)
      expect(subject.search.facets[:title]).to be
    end

    it "asks for the filter" do
      filter = TermFilter.new(:title)
      searcher = described_class.new(params_hash)
      searcher.register filter

      expect(filter).to receive(:filter_for).with(params_hash[:title]).and_return(
        [ bleep: { foo: ['as'] } ]
      )
      searcher.search
    end
  end

  context '.cache_key' do
    it "uses md5 hashing for uniqueness" do
      expect(Digest::MD5).to receive(:hexdigest)
      searcher = described_class.new
      searcher.cache_key
    end

    it "has a consistent length" do
      [{}, { foo: 1, bar: 2 }, { bleep: 22, beef: 312, brap: 333 }].each do |params|
        searcher = described_class.new(params)
        expect(searcher.cache_key.length).to eq 46
      end
    end
  end

  context 'searches' do
    it "dispatches to a registered term search" do
      all_fields = TermSearch.new(:term, :_all)
      searcher = described_class.new(params_hash)
      searcher.register all_fields

      expect(all_fields).to receive(:query_for).with(params_hash[:term], nil)

      searcher.search
    end

    it "dispatches with an operator" do
      all_fields = TermSearch.new(:term, :_all)
      modified_params_hash = params_hash.merge({'term-require-all' => true})
      searcher = described_class.new(modified_params_hash)
      searcher.register all_fields

      expect(all_fields).to receive(:query_for).with(params_hash[:term], 'AND')
      searcher.search
    end
  end
end

class FakeModel
  PER_PAGE = 10
  HIGHLIGHTS = %i(foo bar)
end

def params_hash
  {
    term: 'foo',
    title: 'A title'
  }
end
