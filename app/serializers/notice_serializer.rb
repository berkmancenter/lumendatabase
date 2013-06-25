class NoticeSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :date_received,
    :categories, :submitter_name, :recipient_name, :works

  def categories
    object.categories.map(&:name)
  end

  def works
    object.works.as_json({
      only: [:description, :url],
      include: { infringing_urls: { only: [:url ] } }
    })
  end
end
