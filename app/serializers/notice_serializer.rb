class NoticeSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :date_received, :categories

  def categories
    object.categories.map(&:name)
  end
end
