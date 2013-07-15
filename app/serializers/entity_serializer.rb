class EntitySerializer < ActiveModel::Serializer
  attributes  :id, :parent_id, :name, :address_line_1, :address_line_2, :state,
              :country_code, :phone, :email, :url, :city
end
