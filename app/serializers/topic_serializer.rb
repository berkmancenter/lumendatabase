class TopicSerializer < ActiveModel::Serializer
  attributes :id, :name, :parent_id
end
