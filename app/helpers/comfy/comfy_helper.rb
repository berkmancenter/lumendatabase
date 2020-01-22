module Comfy::ComfyHelper
  def blog_date(cms_page)
    cms_page.created_at.strftime('%B %-d, %Y')
  # If this is being used to preview a page not yet created, the created_at
  # attribute will be nil and the strftime call will fail.
  rescue NoMethodError
    'April 21, 753 BC'
  end

  def blog_posts(cms_site)
    blog_parent = cms_site.pages.where(label: 'blog_entries').first
    scope = Comfy::Cms::Page.where(parent: blog_parent)
                            .order('created_at DESC')
                            .published
    Kaminari.paginate_array(scope.to_a, total_count: scope.count)
            .page(params[:page]).per(10)
  end
end
