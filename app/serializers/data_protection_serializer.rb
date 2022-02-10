class DataProtectionSerializer < NoticeSerializer
  attributes_to_serialize.delete(:body)
  attribute :legal_complaint, &:body

  attribute :works do |object|
    works(object).each do |work|
      swap_keys(work, 'infringing_urls', 'urls_mentioned_in_request')
    end
  end
end
