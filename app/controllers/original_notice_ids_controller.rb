class OriginalNoticeIdsController < ApplicationController
  def show
    notice = Notice.find_by_original_notice_id(params[:id])

    if notice
      redirect_to(notice_path(notice))
    else
      render nothing: true, status: :not_found
    end
  end
end
