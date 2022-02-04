class CourtOrderSerializer < NoticeSerializer
  attribute :laws_referenced do |object|
    object.laws_referenced.map(&:name)
  end

  attributes_to_serialize.delete(:body)
  attribute :explanation, &:body

  attribute :works do |object|
    works(object).each do |work|
      swap_keys(work, 'description', 'subject_of_court_order')
      swap_keys(work, 'infringing_urls', 'targetted_urls')
      work.delete('copyrighted_urls')
    end
  end
end
