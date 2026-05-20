class TrademarkSerializer < NoticeSerializer
  attributes :marks, :mark_registration_number, :regulations

  attribute :regulations do |object|
    object.regulation_list
  end

  attributes_to_serialize.delete(:works)

  attribute :marks do |object|
    if Current.user && Ability.new(Current.user).can?(:view_full_version_api, object)
      object.works.map do |work|
        {
          description: work.description,
          infringing_urls: work.infringing_urls.map(&:url)
        }
      end.as_json
    elsif Current.user && Ability.new(Current.user).can?(:view_enterprise_version, object)
      access = EnterpriseNoticeAccess.new(Current.user, object)

      object.works.map do |work|
        {
          description: work.description,
          infringing_urls: access.serialized_urls(work.infringing_urls, reveal_full: true)
        }
      end.as_json
    else
      object.works.map do |work|
        {
          description: work.description,
          infringing_urls: work.infringing_urls_counted_by_fqdn
        }
      end.as_json
    end
  end
end
