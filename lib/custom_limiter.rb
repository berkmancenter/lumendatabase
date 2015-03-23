class CustomLimiter < Rack::Throttle::Minute
  def allowed?(request)
    path_info = Rails.application.routes.recognize_path request.url rescue {}
    if request.media_type == "application/json"
      if request.env["HTTP_AUTHENTICATION_TOKEN"].nil?
        request.params["size"] = 25
        super
      elsif User.find_by_authentication_token(request.env["HTTP_AUTHENTICATION_TOKEN"]).has_role?(Role.researcher) 
        true
      else
        request.params["size"] = 25
        super  
      end  
    else 
      true
    end
  end
end