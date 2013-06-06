module ApplicationHelper
  def available_categories
    Category.all
  end
end
