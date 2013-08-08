class SearchResultsProxy < SimpleDelegator

  def initialize(result)
    if ['Notice', 'Dmca', 'Defamation', 'Trademark'].include?(result['class_name'])
      result_instance = NoticeSearchResult.new(result)
    else
      result_instance = Tire::Results::Item.new(result)
    end
    super(result_instance)
  end

end
