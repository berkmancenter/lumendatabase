class EntitySerializer < ActiveModel::Serializer
  attributes  :id, :parent_id, :name, :country_code, :url
end
