class CustomLimiter < Rack::Throttle::Minute
  def allowed?(request)
    path_info = Rails.application.routes.recognize_path request.url rescue {}
    #Rails.logger.info "path info"
    #Rails.logger.info path_info
    if (path_info[:controller] == "notices" and path_info[:format] == "json") or request.media_type == "application/json"
      Rails.logger.info "in if"
      request.params["size"] = 25
      #Rails.logger.info path_info
      #Rails.logger.info request.params
      super
    else 
      Rails.logger.info "in else"
      true
    end
  end
end