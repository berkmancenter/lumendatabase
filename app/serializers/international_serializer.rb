class InternationalSerializer < NoticeSerializer
  attribute :regulations

  def regulations
    object.regulation_list
  end

  private

  def attributes
    attributes = super
    swap_keys(attributes, :body, :explanation)
    attributes[:works].each do |work|
      swap_keys(work, 'description', :subject_of_complaint)
      swap_keys(work, :copyrighted_urls, :original_work_urls)
      swap_keys(work, :infringing_urls, :offending_urls)
    end
    attributes
  end

end
