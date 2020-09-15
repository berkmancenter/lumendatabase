require 'spec_helper'

describe TermFilter, type: :model do
  it 'has an indexed attribute that defaults to the parameter name' do
    facet = :term_facet
    term_search = described_class.new(facet)
    expect(term_search.as_elasticsearch_filter(facet, 'foo')).to eq(
      { term: { term_facet: 'foo' } }
    )
  end

  it 'can override the indexed attribute name' do
    facet = :term_facet
    term_search = described_class.new(facet, 'title', :indexed_attribute_name)
    expect(term_search.as_elasticsearch_filter(facet, 'foo')).to eq(
      { term: { indexed_attribute_name: 'foo' } }
    )
  end

  it 'does not provide a filter with a parameter it is not bound to' do
    term_search = described_class.new(:term_facet)
    expect(term_search.as_elasticsearch_filter(:not_the_facet, 'foo')).to be_nil
  end
end
