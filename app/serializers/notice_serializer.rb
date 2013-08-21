class NoticeSerializer < ActiveModel::Serializer
  attributes :id, :type, :title, :body, :date_sent, :date_received,
    :categories, :sender_name, :recipient_name, :works, :tags, :jurisdictions

  # TODO - serialize additional entities

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
    attributes = super

    if object.respond_to?(:_score)
      attributes.merge!(score: object._score)
    end

    attributes
  end

  def swap_keys(hash, original_key, new_key)
    original_value = hash.delete(original_key)
    hash[new_key] = original_value
  end

end
