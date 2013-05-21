class HomeController < ApplicationController
  def index
    @notices = Notice.recent
  end

end
