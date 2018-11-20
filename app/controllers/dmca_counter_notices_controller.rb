class DMCACounterNoticesController < ApplicationController
  def new
    @dmca_counter_notice = DMCACounterNotice.new
  end

  def create
    @dmca_counter_notice = DMCACounterNotice.new(params[:dmca_counter_notice])

    return unless @dmca_counter_notice.valid?

    render :show
  end

  def show
    @dmca_counter_notice = DMCACounterNotice.new(params[:dmca_counter_notice])
  end
end
