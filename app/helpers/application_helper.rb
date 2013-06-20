module ApplicationHelper
  def available_categories
    Category.ordered
  end

  def category_roots
    Category.ordered.roots
  end
end
