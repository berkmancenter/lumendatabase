class SearchResultsProxy < SimpleDelegator

  def initialize(result)
    if result['_type'] == 'notice'
      result_instance = NoticeSearchResult.new(result)
    else
      result_instance = Tire::Results::Item.new(result)
    end
    super(result_instance)
  end

end
