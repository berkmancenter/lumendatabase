class CustomLimiter < Rack::Throttle::Minute
  def allowed?(request)
    #path_info = Rails.application.routes.recognize_path request.url rescue {}
    if request.media_type == "application/json"
      Rails.logger.info request.env["HTTP_AUTHENTICATION_TOKEN"]
      if request.env["HTTP_AUTHENTICATION_TOKEN"].nil?
        request.GET[:per_page] = 25
        super
      elsif User.find_by_authentication_token(request.env["HTTP_AUTHENTICATION_TOKEN"]).has_role?(Role.researcher) 
        true
      else
        request.GET[:per_page] = 25
        super  
      end  
    else 
      true
    end
  end
end