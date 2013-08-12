class NoticeSearchResultSerializerProxy < SimpleDelegator
  def initialize(*args)
    model_instance = args[0]
    if model_instance.type == 'Trademark'
      model_instance = TrademarkSerializer.new(model_instance)
    else
      model_instance = NoticeSerializer.new(model_instance)
    end
    super(model_instance)
  end
end
