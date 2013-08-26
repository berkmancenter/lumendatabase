module ApplicationHelper
  def available_categories
    Category.ordered
  end

  def category_roots
    Category.ordered.roots
  end

  def title(page_header, page_description = nil)
    full_title = [
      page_description,
      page_header,
      'Chilling Effects'
    ].compact.join(' :: ')

    content_for(:title) { full_title }
    content_for(:header) { page_header }
  end
end
