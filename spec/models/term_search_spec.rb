require 'spec_helper'

describe TermSearch, type: :model do

  before do
    @term_search = described_class.new(:term, :_all)
    @query = double("SearchesModels query object")
  end

  it "queries the searcher given a param it handles" do
    expect(@query).to receive(:boolean)
    @term_search.apply_to_query(@query, :term, 'foo', nil)
  end

  it "does not query with a parameter it is not bound to" do
    expect(@query).not_to receive(:boolean)
    @term_search.apply_to_query(@query, :unknown_term, 'foo', nil)
  end

end
