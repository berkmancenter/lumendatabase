class TrademarkSerializer < NoticeSerializer
  attributes :marks, :mark_registration_number, :regulations

  attribute :regulations do |object|
    object.regulation_list
  end

  attributes_to_serialize.delete(:works)

  attribute :marks do |object|
    user = Current.user
    ability = user && Lumen::Ability.new(user)

    if user && ability.can?(:view_full_version_api, object)
      enterprise_access = enterprise_api_access_enabled? && ability.can?(:view_enterprise_version, object) ?
        Lumen::Enterprise::NoticeAccess.new(user, object) : nil

      object.works.map do |work|
        rows = Lumen::WorkUrlRows.new(work: work, type: 'infringing', notice: object, user: user)
          .visible_rows(enterprise_access: enterprise_access)
        api_rows = serialize_url_rows(rows)

        {
          description: work.description,
          infringing_urls: api_rows.any? { |r| r[:fqdn] } ? api_rows : work.infringing_urls.map(&:url)
        }
      end.as_json
    elsif user && enterprise_api_access_enabled? && ability.can?(:view_enterprise_version, object)
      access = Lumen::Enterprise::NoticeAccess.new(user, object)

      object.works.map do |work|
        {
          description: work.description,
          infringing_urls: access.serialized_urls(work.infringing_urls_public)
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
