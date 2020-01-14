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
    scope = blog_parent.children.published
    Kaminari.paginate_array(scope.to_a, total_count: scope.count)
            .page(params[:page]).per(10)
  end

  def fragment_title(page)
    if (title = page.fragments.find_by_identifier('title').content).empty?
      title = '(No title)'
    end
    # This can't return an empty string. Since we use the title to construct
    # links to the blog post, there must be something to click on.
    title
  end

  def fragment_content(page)
    page.fragments.find_by_identifier('content').content
  end

  def fragment_abstract(page)
    page.fragments.find_by_identifier('abstract').content
  rescue NoMethodError
    nil
  end
end
