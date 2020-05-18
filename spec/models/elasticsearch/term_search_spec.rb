require 'spec_helper'

describe TermSearch, type: :model do
  before do
    @field = :_all
    @term_search = described_class.new(:term, @field)
  end

  it 'provides a query given a param it handles' do
    expect(@term_search.as_elasticsearch_query(:term, 'foo', nil)).to eq(
      [{:match=>{@field=>{:query=>'foo', :operator=>'OR'}}}]
    )
  end

  it 'does not provide a query with a parameter it is not bound to' do
    expect(@term_search.as_elasticsearch_query(:unknown_term, 'foo', nil)).to be_nil
  end
end
