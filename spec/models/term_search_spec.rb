require 'spec_helper'

describe TermSearch do

  before do
    @term_search = described_class.new(:term, :_all)
    @searcher = double("SearchesModels Instance")
  end

  it "queries the searcher given a param it handles" do
    @searcher.should_receive(:query)
    @term_search.apply_to_search(@searcher, :term, 'foo')
  end

  it "does not query with a parameter it is not bound to" do
    @searcher.should_not_receive(:query)
    @term_search.apply_to_search(@searcher, :unknown_term, 'foo')
  end

end
