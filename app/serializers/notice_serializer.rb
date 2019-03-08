class NoticeSerializer < ActiveModel::Serializer
  attributes :id, :type, :title, :body, :date_sent, :date_received,
             :topics, :sender_name, :principal_name, :recipient_name, :works,
             :tags, :jurisdictions, :action_taken, :language

  has_many :works

  # TODO: serialize additional entities

  def topics
    object.topics.map(&:name)
  end

  def tags
    object.tag_list
  end

  def jurisdictions
    object.jurisdiction_list
  end

  private

  def attributes
    attributes = super || []

    attributes[:score] = object._score if object.respond_to?(:_score)

    attributes
  end

  def swap_keys(hash, original_key, new_key)
    original_value = hash.delete(original_key)
    hash[new_key] = original_value
  end
end
