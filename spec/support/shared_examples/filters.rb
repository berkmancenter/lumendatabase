shared_examples "a search filter" do

  before do
    @filter = described_class.new(:facet, [])
    @searcher = {
      registered_filters: [],
      filters: []
    }
  end

  it "registers a facet" do
    expect(@searcher[:registered_filters]).to receive(:<<)

    @filter.register_filter(@searcher)
  end

  it "registers a filter" do
    expect(@searcher[:filters]).to receive(:<<)

    @filter.apply_to_search(@searcher, :facet, '')
  end

  it "queries the searcher given a param it handles" do
    expect(@searcher[:filters]).to receive(:<<)

    @filter.apply_to_search(@searcher, :facet, 'foo')
  end

  it "does not query with a parameter it is not bound to" do
    expect(@searcher[:filters]).not_to receive(:<<)

    @filter.apply_to_search(@searcher, :unknown_term, 'foo')
  end
end
