require 'spec_helper'

describe TermFilter, type: :model do

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

end
