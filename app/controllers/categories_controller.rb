class CategoriesController < ApplicationController

  def index
    render json: Category.all
  end

  def show
    @category = Category.find(params[:id])
  end

end
