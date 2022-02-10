class TrademarkSerializer < NoticeSerializer
  attributes :marks, :mark_registration_number

  attributes_to_serialize.delete(:works)

  attribute :marks do |object|
    if Current.user && Ability.new(Current.user).can?(:view_full_version_api, object)
      object.works.map do |work|
        {
          description: work.description,
          infringing_urls: work.infringing_urls.map(&:url)
        }
      end.as_json
    else
      object.works.map do |work|
        {
          description: work.description,
          infringing_urls: work.infringing_urls_counted_by_domain
        }
      end.as_json
    end
  end
end
