class LocalLawSerializer < NoticeSerializer
  attributes_to_serialize.delete(:body)
  attribute :explanation, &:body

  attribute :works do |_object|
    [
      {
        problematic_urls: [
          { url: Lumen::REDACTION_MASK }
        ]
      }
    ]
  end
end
