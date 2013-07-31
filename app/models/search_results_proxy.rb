class SearchResultsProxy < SimpleDelegator

  def initialize(result)
    if ['notice', 'trademark'].include?(result['_type'])
      result_instance = NoticeSearchResult.new(result)
    else
      result_instance = Tire::Results::Item.new(result)
    end
    super(result_instance)
  end

end
