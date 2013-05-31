class NoticeSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :date_received, :categories, :notice_file_content

  def categories
    object.categories.map(&:name)
  end
end
