class LocalLawSerializer < OtherSerializer
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
