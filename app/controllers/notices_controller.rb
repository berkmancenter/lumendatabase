class NoticesController < ApplicationController

  def show
    @notice = Notice.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @notice }
    end
  end

end
