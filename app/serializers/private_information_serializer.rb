class PrivateInformationSerializer < NoticeSerializer

  private

  def attributes
    attributes = super
    swap_keys(attributes, :body, :explanation)
    attributes[:works].each do |work|
      swap_keys(work, 'description', :complaint)
      swap_keys(work, :infringing_urls, :urls_with_private_information)
    end
    attributes
  end

end
