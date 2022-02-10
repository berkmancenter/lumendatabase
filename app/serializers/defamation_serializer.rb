class DefamationSerializer < NoticeSerializer
  attributes_to_serialize.delete(:body)
  attribute :legal_complaint, &:body

  attribute :works do |object|
    works(object).each do |work|
      swap_keys(work, 'infringing_urls', 'defamatory_urls')
      work.delete('copyrighted_urls')
    end
  end
end
