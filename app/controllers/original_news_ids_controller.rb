class OriginalNewsIdsController < RedirectingController
  def show
    super(BlogEntry, :find_by_original_news_id)
  end
end
