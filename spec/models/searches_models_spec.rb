require 'spec_helper'

describe SearchesModels do

  it "returns an elasticsearch search instance" do
    expect(subject.search).to be_instance_of(Tire::Search::Search)
  end

  it "finds the index_name from the model_class" do
    FakeModel.should_receive(:index_name)

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

      filter.should_receive(:filter_for).with(params_hash[:title]).and_return(
        [ bleep: { foo: ['as'] } ]
      )
      searcher.search
    end
  end

  context 'searches' do
    it "dispatches to a registered term search" do
      all_fields = TermSearch.new(:term, :_all)
      searcher = described_class.new(params_hash)
      searcher.register all_fields

      all_fields.should_receive(:query_for).with(params_hash[:term], nil)

      searcher.search
    end

    it "dispatches with an operator" do
      all_fields = TermSearch.new(:term, :_all)
      modified_params_hash = params_hash.merge({'term-require-all' => true})
      searcher = described_class.new(modified_params_hash)
      searcher.register all_fields

      all_fields.should_receive(:query_for).with(params_hash[:term], 'AND')
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
