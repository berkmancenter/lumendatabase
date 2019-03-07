class OtherSerializer < NoticeSerializer
  private

  def attributes
    attributes = super
    swap_keys(attributes, :body, :explanation)
    attributes[:works].each do |work|
      swap_keys(work, 'description', 'complaint')
      swap_keys(work, 'copyrighted_urls', 'original_work_urls')
      swap_keys(work, 'infringing_urls', 'problematic_urls')
    end
    attributes
  end
end
