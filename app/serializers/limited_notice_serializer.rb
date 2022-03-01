class LimitedNoticeSerializer < BaseSerializer
  attributes :id, :type, :title, :body, :date_sent, :date_received,
             :topics, :sender_name, :principal_name, :recipient_name, :works,
             :tags, :jurisdictions, :action_taken, :language, :case_id_number

  # TODO: serialize additional entities

  attribute :topics do |object|
    object.topics.map(&:name)
  end

  attribute :works do |object|
    object.works.as_json(
      only: [:description],
      include: {
        infringing_urls: { only: [:url] },
        copyrighted_urls: { only: [:url] }
      }
    )
  end

  attribute :tags do |object|
    object.tag_list
  end

  attribute :jurisdictions do |object|
    object.jurisdiction_list
  end

  attribute :score, if: proc { |record|
    record.respond_to?(:_score)
  } do |object|
    object._score
  end

  def self.swap_keys(hash, original_key, new_key)
    original_value = hash.delete(original_key)
    hash[new_key] = original_value
  end
end
