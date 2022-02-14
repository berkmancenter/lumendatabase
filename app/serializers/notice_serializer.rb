class NoticeSerializer < BaseSerializer
  attributes :id, :type, :title, :body, :date_sent, :date_received,
             :topics, :sender_name, :principal_name, :recipient_name, :works,
             :tags, :jurisdictions, :action_taken, :language, :case_id_number

  # Data to be returned when a Work has no associated URL.
  FALLBACK = [{ url: 'No URL submitted' }].freeze

  # TODO: serialize additional entities

  attribute :topics do |object|
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
  attribute :works do |object|
    works(object)
  end

  attribute :tags, &:tag_list

  attribute :jurisdictions, &:jurisdiction_list

  attribute :score, if: proc { |record|
    record.respond_to?(:_score)
  } do |object|
    object._score
  end

  def self.swap_keys(hash, original_key, new_key)
    original_value = hash.delete(original_key)
    hash[new_key] = original_value
  end

  def self.cleaned_works(base_works)
    base_works.each do |work|
      work['infringing_urls'] = FALLBACK if work['infringing_urls'].empty?
      work['copyrighted_urls'] = FALLBACK if work['copyrighted_urls'].empty?
    end
    base_works
  end

  def self.works(object)
    if defined?(Current.user) && Current.user && Ability.new(Current.user).can?(:view_full_version_api, object)
      base_works = object.works.map do |work|
        {
          description: work.description,
          infringing_urls: work.infringing_urls.map { |iurl| { url: iurl.url } },
          copyrighted_urls: work.copyrighted_urls.map { |curl| { url: curl.url } }
        }
      end.as_json
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
end
