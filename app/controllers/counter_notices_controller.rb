class CounterNoticesController < ApplicationController
  def new
    @counter_notice = CounterNotice.new
  end

  def create
    @counter_notice = CounterNotice.new(params[:counter_notice])
    if @counter_notice.valid?
      render :show
    end
  end

  def show
    @counter_notice = CounterNotice.new(params[:counter_notice])
  end

end
