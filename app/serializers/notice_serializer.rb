class NoticeSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :date_sent, :date_received,
    :categories, :sender_name, :recipient_name, :works, :tags, :jurisdictions


  def categories
    object.categories.map(&:name)
  end

  def works
    object.works.as_json({
      only: [:description],
      include: {
        infringing_urls: { only: [:url ] },
        copyrighted_urls: { only: [:url ] }
      }
    })
  end

  def tags
    object.tag_list
  end

  def jurisdictions
    object.jurisdiction_list
  end

  private

  def attributes
    hsh = super

    if object.respond_to?(:_score)
      hsh.merge!(score: object._score)
    end

    hsh
  end

end
