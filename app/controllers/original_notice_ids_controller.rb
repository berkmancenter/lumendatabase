class OriginalNoticeIdsController < RedirectingController
  def show
    super(Notice, :find_by_original_notice_id)
  end
end
