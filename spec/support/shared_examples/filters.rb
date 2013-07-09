shared_examples "a search filter" do

  before do
    @filter = described_class.new(:facet, [])
    @searcher = double("NoticeSearcher Instance")
  end

  it "registers a facet" do
    @searcher.should_receive(:facet)

    @filter.register_filter(@searcher)
  end

  it "registers a filter" do
    @searcher.should_receive(:filter)

    @filter.apply_to_search(@searcher, :facet, '')
  end

  it "queries the searcher given a param it handles" do
    @searcher.should_receive(:filter)

    @filter.apply_to_search(@searcher, :facet, 'foo')
  end

  it "does not query with a parameter it is not bound to" do
    @searcher.should_not_receive(:filter)

    @filter.apply_to_search(@searcher, :unknown_term, 'foo')
  end
end
