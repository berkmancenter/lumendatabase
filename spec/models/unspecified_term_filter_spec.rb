require 'spec_helper'

describe UnspecifiedTermFilter, type: :model do

  it_behaves_like 'a search filter'

  it "has an indexed attribute that defaults to the parameter name" do
    term_search = described_class.new(:term_facet)
    expect(term_search.filter_for('foo')).to eq(
      [:terms, :term_facet => [ 'foo' ]]
    )
  end

  it "can override the indexed attribute name" do
    term_search = described_class.new(:term_facet, 'title', :indexed_attribute_name)
    expect(term_search.filter_for('foo')).to eq(
      [:terms, :indexed_attribute_name => [ 'foo' ]]
    )
  end

  context "#apply_to_search" do
    let(:facet) { :some_facet }
    let(:searcher) { Tire.search 'some_index' }
    let(:term_search) do
      described_class.new(facet, 'title')
    end
    let(:test_case) do
      term_search.apply_to_search(
        searcher,
        @param,
        "true"
      )
    end

    it "adds a complex filter to searcher when the unspecified param is used" do
      expected = "{\"filter\":{\"bool\":{\"should\":[{\"terms\":{\"some_facet\":[\"\"]}},{\"missing\":{\"field\":\"some_facet\"}}]}}}"
      @param = described_class.unspecified_identifier(facet)
      expect { test_case }.to change { searcher.to_json }.from("{}").to(expected)
    end

    it "adds a basic filter to searcher when the regular param is used" do
      expected = "{\"filter\":{\"terms\":{\"some_facet\":[\"true\"]}}}"
      @param = facet
      expect { test_case }.to change { searcher.to_json }.from("{}").to(expected)
    end

    it "does not add a filter to searcher when an inapplicable param is used" do
      @param = "not_a_facet"
      expect { test_case }.not_to change { searcher.to_json }.from("{}")
    end
  end
end
