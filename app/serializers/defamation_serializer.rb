class DefamationSerializer < NoticeSerializer

  def attributes
    attributes = super
    swap_keys(attributes, :body, :legal_complaint)
    attributes[:works].each do |work|
      swap_keys(work, 'infringing_urls', :defamatory_urls)
      work.delete('copyrighted_urls')
    end
    attributes
  end
end
