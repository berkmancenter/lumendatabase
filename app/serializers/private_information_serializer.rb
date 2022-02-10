class PrivateInformationSerializer < NoticeSerializer
  attributes_to_serialize.delete(:body)
  attribute :explanation, &:body

  attribute :works do |object|
    works(object).each do |work|
      swap_keys(work, 'description', 'complaint')
      swap_keys(work, 'infringing_urls', 'urls_with_private_information')
    end
  end
end
