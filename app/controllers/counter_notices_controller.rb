class CounterNoticesController < ApplicationController
  def new
    @counter_notice = CounterNotice.new
  end

  def create
    @counter_notice = CounterNotice.new(params[:counter_notice])
    render :show if @counter_notice.valid?
  end

  def show
    @counter_notice = CounterNotice.new(params[:counter_notice])
  end
end
