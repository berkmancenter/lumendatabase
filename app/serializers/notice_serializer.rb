class NoticeSerializer < ActiveModel::Serializer
  attributes :id, :type, :title, :body, :date_sent, :date_received,
    :topics, :sender_name, :principal_name, :recipient_name, :works,
    :tags, :jurisdictions, :action_taken, :language

  # TODO - serialize additional entities

  def topics
    object.topics.map(&:name)
  end

  def works
    if current_user && Ability.new(scope).can?(:view_full_version_api, object)
      object.works.as_json(
        only: [:description],
        include: {
          infringing_urls: { only: %i[url url_original] },
          copyrighted_urls: { only: %i[url url_original] }
        }
      )
    else
      object.works.map do |work|
        {
          description: work.description,
          infringing_urls: work.infringing_urls_counted_by_domain,
          copyrighted_urls: work.copyrighted_urls_counted_by_domain
        }
      end.as_json
    end
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
