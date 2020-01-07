module Comfy::ComfyHelper
  def blog_date(cms_page)
    cms_page.created_at.strftime('%B %-d, %Y')
  # If this is being used to preview a page not yet created, the created_at
  # attribute will be nil and the strftime call will fail.
  rescue NoMethodError
    'April 21, 753 BC'
  end
end
