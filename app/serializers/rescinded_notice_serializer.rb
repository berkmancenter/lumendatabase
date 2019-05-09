class RescindedNoticeSerializer < ActiveModel::Serializer
  self.root = :notice

  attributes :id, :title, :body

  def body
    'Notice Rescinded'
  end
end
