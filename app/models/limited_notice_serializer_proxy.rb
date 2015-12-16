class LimitedNoticeSerializerProxy < SimpleDelegator
  def initialize(instance, *args)
    serializer = instance.active_model_serializer || NoticeSerializer
    serialized = serializer.new(instance, *args)

    super(serialized)
  end
end
