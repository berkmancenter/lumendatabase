class SearchResultsProxy < SimpleDelegator

  def initialize(result)
    if (model_class = get_model_class(result)) && model_class <= Notice
      result_instance = NoticeSearchResult.new(model_class.new, result)
    else
      result_instance = Tire::Results::Item.new(result)
    end

    super(result_instance)
  end

  private

  def get_model_class(result)
    result.has_key?('class_name') &&
      result['class_name'].classify.constantize
  end

end
