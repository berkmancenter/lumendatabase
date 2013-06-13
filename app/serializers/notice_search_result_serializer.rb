class NoticeSearchResultSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :date_received, :categories, :score

  def categories
    object.categories.map(&:name)
  end

  def score
    object._score
  end
end
