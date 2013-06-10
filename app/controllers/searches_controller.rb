class SearchesController < ApplicationController

  def show
    q = params[:q]
    p = params[:page]

    @results = Notice.search(page: p) do
      query { match(:_all, q) }

      highlight(*Notice::HIGHLIGHTS)
    end
  end

end
