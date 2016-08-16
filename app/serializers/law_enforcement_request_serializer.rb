class LawEnforcementRequestSerializer < NoticeSerializer
  attributes :regulations, :request_type

  def regulations
    object.regulation_list.map(&:name)
  end

  private

  def attributes
    attributes = super
    swap_keys(attributes, :body, :explanation)
    attributes[:works].each do |work|
      swap_keys(work, 'description', :subject_of_enforcement_request)
      swap_keys(work, :copyrighted_urls, :original_work_urls)
      swap_keys(work, :infringing_urls, :urls_in_request)
    end
    attributes
  end

end
