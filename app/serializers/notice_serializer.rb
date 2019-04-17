class NoticeSerializer < ActiveModel::Serializer
  attributes :id, :type, :title, :body, :date_sent, :date_received,
             :topics, :sender_name, :principal_name, :recipient_name, :works,
             :tags, :jurisdictions, :action_taken, :language

  # Data to be returned when a Work has no associated URL.
  FALLBACK = [{ url: 'No URL submitted' }].freeze

  # TODO: serialize additional entities

  def topics
    object.topics.map(&:name)
  end

  # It would be cleaner to define a WorkSerializer and follow
  # active-model-serializer conventions. However, we rename fields on Work in
  # our API responses, conditionally upon the type of Notice associated. That
  # is not a use case anticipated by active-model-serializer, and it turns out
  # to be much easier to define the work attribute here, and then have it
  # accessible as a hash (rather than as an object to be serialized) so we can
  # use hash operations on it within the hooks supported by
  # active-model-serializer.
  def works
    if current_user && Ability.new(scope).can?(:view_full_version_api, object)
      base_works = object.works.as_json(
        only: [:description],
        include: {
          infringing_urls: { only: %i[url url_original] },
          copyrighted_urls: { only: %i[url url_original] }
        }
      )
    else
      base_works = object.works.map do |work|
        {
          description: work.description,
          infringing_urls: work.infringing_urls_counted_by_domain,
          copyrighted_urls: work.copyrighted_urls_counted_by_domain
        }
      end.as_json
    end
    cleaned_works(base_works)
  end

  def cleaned_works(base_works)
    base_works.each do |work|
      work['infringing_urls'] = FALLBACK if work['infringing_urls'].empty?
      work['copyrighted_urls'] = FALLBACK if work['copyrighted_urls'].empty?
    end
    base_works
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
