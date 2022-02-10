class BaseSerializer
  include JSONAPI::Serializer

  def as_json(options={})
    serializable_hash[:data]
  end
end
