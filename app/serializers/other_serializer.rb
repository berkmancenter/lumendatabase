class OtherSerializer < NoticeSerializer
  attributes_to_serialize.delete(:body)
  attribute :explanation, &:body

  attribute :works do |object|
    works(object).each do |work|
      swap_keys(work, 'description', 'complaint')
      swap_keys(work, 'copyrighted_urls', 'original_work_urls')
      swap_keys(work, 'infringing_urls', 'problematic_urls')
    end
  end
end
