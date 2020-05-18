require 'spec_helper'

describe UnspecifiedTermFilter, type: :model do
  it 'supplies a basic filter when the regular param is used' do
    facet = :term_facet
    term_search = described_class.new(facet)
    # Make handles? true but unspecified_param? false.
    dummy_param = facet

    expect(term_search.as_elasticsearch_filter(dummy_param, 'foo')).to eq(
      { term: { term_facet: 'foo' } }
    )
  end

  it 'supplies a complex filter when the unspecified param is used' do
    facet = :term_facet
    term_search = described_class.new(facet)
    dummy_param = described_class.unspecified_identifier(facet)

    expect(term_search.as_elasticsearch_filter(dummy_param, 'foo')).to eq(
      {
        bool: {
          should: [
            { terms: { term_facet: '' } },
            { missing: { field: :term_facet } }
          ]
        }
      }
    )
  end

  it 'does not supply a filter when an inapplicable param is used' do
    facet = 'not_a_facet'
    term_search = described_class.new(facet)
    # Make handles? true but unspecified_param? false.
    dummy_param = facet

    expect(term_search.as_elasticsearch_filter(dummy_param, 'foo')).to be_nil
  end

  it 'can override the indexed attribute name' do
    facet = :term_facet
    term_search = described_class.new(
      facet, 'title', :indexed_attribute_name
    )
    dummy_param = facet

    expect(term_search.as_elasticsearch_filter(dummy_param, 'foo')).to eq(
      { term: { indexed_attribute_name: 'foo' } }
    )
  end
end
