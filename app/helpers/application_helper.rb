module ApplicationHelper
  def available_categories
    Category.all
  end

  def category_roots
    Category.ordered.roots
  end
end
