module Comfy::ComfyHelper
  include Comfy::Paginate

  def blog_date(cms_page)
    cms_page.created_at.strftime('%B %-d, %Y')
  # If this is being used to preview a page not yet created, the created_at
  # attribute will be nil and the strftime call will fail.
  rescue NoMethodError
    'April 21, 753 BC'
  end

  def blog_posts(cms_site)
    blog_parent = cms_site.pages.where(label: 'blog_entries').first
    scope = blog_parent.children.published
    Kaminari.paginate_array(scope.to_a, total_count: scope.count)
            .page(params[:page]).per(10)
  end

  def fragment_title(page)
    page.fragments.find_by_identifier('title').content
  end

  def fragment_content(page)
    page.fragments.find_by_identifier('content').content
  end
end
