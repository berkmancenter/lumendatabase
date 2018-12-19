class TrademarkSerializer < NoticeSerializer
  attributes :marks, :mark_registration_number

  def marks
    if current_user && Ability.new(scope).can?(:view_full_version_api, object)
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

  private

  def attributes
    hsh = super
    hsh.delete(:works)

    hsh
  end
end
