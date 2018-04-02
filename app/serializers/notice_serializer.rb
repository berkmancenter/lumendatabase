class NoticeSerializer < ActiveModel::Serializer
  attributes :id, :type, :title, :body, :date_sent, :date_received,
    :topics, :sender_name, :principal_name, :recipient_name, :works,
    :tags, :jurisdictions, :action_taken, :language

  # TODO - serialize additional entities

  def topics
    object.topics.map(&:name)
  end

  def works
    object.works.as_json({
      only: [:description],
      include: {
        infringing_urls: { only: [:url, :url_original ] },
        copyrighted_urls: { only: [:url, :url_original ] }
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
