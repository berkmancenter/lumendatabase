class NoticeSerializerProxy < SimpleDelegator
  def initialize(instance, *args)
    serializer = instance.model_serializer || NoticeSerializer
    serialized = serializer.new(instance, *args)

    super(serialized)
  end
end
