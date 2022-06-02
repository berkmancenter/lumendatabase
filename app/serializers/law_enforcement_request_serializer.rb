class LawEnforcementRequestSerializer < NoticeSerializer
  attributes :regulations, :request_type

  attribute :regulations do |object|
    object.regulation_list
  end

  attributes_to_serialize.delete(:body)
  attribute :explanation, &:body

  attribute :works do |object|
    works(object).each do |work|
      swap_keys(work, 'description', 'subject_of_enforcement_request')
      swap_keys(work, 'copyrighted_urls', 'original_work_urls')
      swap_keys(work, 'infringing_urls', 'urls_in_request')
    end
  end
end
