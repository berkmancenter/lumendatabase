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

  def blog_search_engine_configured?
    Chill::Application.config.google_custom_blog_search_id.present?
  end

  def page_path(label)
    Comfy::Cms::Page.find_by_label(label).full_path
  # If someone tries to use this on an undefined page, we'll return something
  # that will probably 404. That means we will probably notice the page is
  # missing, but we won't crash the site -- especially useful in development,
  # as localhost may not have a fully defined set of pages.
  rescue NoMethodError
    "pages/#{label}"
  end
end
