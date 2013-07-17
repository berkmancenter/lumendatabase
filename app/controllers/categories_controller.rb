class CategoriesController < ApplicationController

  def index
    render json: Category.all
  end

  def show
    @category = Category.find(params[:id])
    searcher = category_notice_searcher(@category.name)

    @notices = searcher.results
  end

  private

  def category_notice_searcher(category_name)
    searcher = SearchesModels.new({ category: category_name })
    searcher.register TermSearch.new(:category, :category_facet)
    searcher.sort_by = :date_received, :desc
    searcher.search
  end

end
