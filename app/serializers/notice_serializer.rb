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

  attribute :date_submitted, &:created_at

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

  def self.full_urls(notice, url_instances, content_filters: nil, permissions: nil)
    content_filters ||= ContentFilter.url_filters_matching_notice(notice)
    permissions ||= ContentFilter.user_permissions(Current.user)
    grouped_urls = {}

    url_instances.filter_map do |url_instance|
      matching_filters = ContentFilter.matching_url_filters(
        notice,
        url_instance,
        content_filters: content_filters
      )

      case ContentFilter.url_action(
        notice,
        url_instance,
        Current.user,
        content_filters: matching_filters,
        permissions: permissions
      )
      when :hidden
        nil
      when :restricted
        grouped_url(url_instance.url, grouped_urls)
      else
        if lumen_team_filtered_for_admin?(matching_filters, permissions)
          grouped_url(
            url_instance.url,
            grouped_urls,
            redaction_filters: matching_filters
          )
        else
          { url: url_instance.url }
        end
      end
    end
  end

  def self.works(object)
    if defined?(Current.user) && Current.user && Ability.new(Current.user).can?(:view_full_version_api, object)
      content_filters = ContentFilter.url_filters_matching_notice(object)
      permissions = ContentFilter.user_permissions(Current.user)

      base_works = object.works.map do |work|
        {
          description: work.description,
          infringing_urls: full_urls(
            object,
            work.infringing_urls,
            content_filters: content_filters,
            permissions: permissions
          ),
          copyrighted_urls: full_urls(
            object,
            work.copyrighted_urls,
            content_filters: content_filters,
            permissions: permissions
          )
        }
      end.as_json
    elsif defined?(Current.user) && Current.user && Ability.new(Current.user).can?(:view_enterprise_version, object)
      access = EnterpriseNoticeAccess.new(Current.user, object)

      base_works = object.works.map do |work|
        {
          description: work.description,
          infringing_urls: access.serialized_urls(work.infringing_urls_public),
          copyrighted_urls: access.serialized_urls(work.copyrighted_urls_public)
        }
      end.as_json
    else
      base_works = object.works.map do |work|
        {
          description: work.description,
          infringing_urls: work.infringing_urls_counted_by_fqdn,
          copyrighted_urls: work.copyrighted_urls_counted_by_fqdn
        }
      end.as_json
    end
    cleaned_works(base_works)
  end

  def self.grouped_url(url, grouped_urls, redaction_filters: [])
    fqdn = Work.fqdn_from_url(url).presence || url
    fqdn = redact_fqdn_filter_text(fqdn, redaction_filters)
    key = fqdn.downcase

    grouped_urls[key] ||= { fqdn: fqdn, count: 0 }
    grouped_urls[key][:count] += 1

    grouped_urls[key] if grouped_urls[key][:count] == 1
  end

  def self.lumen_team_filtered_for_admin?(matching_filters, permissions)
    permissions[:lumen_team] &&
      matching_filters.any? { |content_filter| content_filter.has_action?(:full_notice_version_only_lumen_team) }
  end

  def self.redact_fqdn_filter_text(fqdn, filters)
    filters.reduce(fqdn) do |redacted_fqdn, content_filter|
      next redacted_fqdn unless content_filter.has_action?(:full_notice_version_only_lumen_team)
      next redacted_fqdn if content_filter.url_text.blank?

      redacted_fqdn.gsub(/#{Regexp.escape(content_filter.url_text)}/i, '[REDACTED]')
    end
  end
end
