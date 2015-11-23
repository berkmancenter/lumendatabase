# In config/initializers/rack-attack.rb
class Rack::Attack
  
  # Always allow requests from localhost
  # (blacklist & throttles are skipped)
  whitelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
    '127.0.0.1' == req.ip
  end

  whitelist('allow unlimited requests from API users') do |req|
  	#Unlimited requests allowed if user has a valid API key
  	if req.params['authentication_token'].presence
      User.find_by_authentication_token(req.params['authentication_token']).has_role?(Role.researcher) ||
        User.find_by_authentication_token(req.params['authentication_token']).has_role?(Role.submitter)
    elsif req.env.key?("HTTP_AUTHENTICATION_TOKEN")
      User.find_by_authentication_token(req.env["HTTP_AUTHENTICATION_TOKEN"]).has_role?(Role.researcher) ||
      User.find_by_authentication_token(req.env["HTTP_AUTHENTICATION_TOKEN"]).has_role?(Role.submitter)
    end
  end

  throttle('req/ip', :limit => 300, :period => 5.minutes) do |req|
  	req.ip
  end

  throttle('users/sign_in', :limit => 5, :period => 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.ip
    end
  end
end