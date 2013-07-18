class NoticeSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :date_sent, :date_received,
    :categories, :sender_name, :recipient_name, :works, :tags, :jurisdictions

  def categories
    object.categories.map(&:name)
  end

  def works
    object.works.as_json({
      only: [:description, :url],
      include: { infringing_urls: { only: [:url ] } }
    })
  end

  def tags
    object.tag_list
  end

  def jurisdictions
    object.jurisdiction_list
  end
end
