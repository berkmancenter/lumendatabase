class DataProtectionSerializer < NoticeSerializer

  def attributes
    attributes = super
    swap_keys(attributes, :body, :legal_complaint)
    attributes[:works].each do |work|
      swap_keys(work, :infringing_urls, :urls_mentioned_in_request)
    end
    attributes
  end
end
