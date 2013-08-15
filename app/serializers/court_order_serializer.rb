class CourtOrderSerializer < NoticeSerializer
  attribute :regulations

  def regulations
    object.regulation_list
  end

  private

  def attributes
    attributes = super
    swap_keys(attributes, :body, :explanation)
    attributes[:works].each do |work|
      swap_keys(work, 'description', :subject_of_court_order)
      swap_keys(work, :infringing_urls, :targetted_urls)
      work.delete(:copyrighted_urls)
    end
    attributes
  end
end
