# In config/initializers/rack-attack.rb
class Rack::Attack
  # Always allow requests from localhost
  # (blacklist & throttles are skipped)
  #whitelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
  #  '127.0.0.1' == req.ip
  #end

  whitelist('allow from API users') do |req|
  	#Requests allowed if user has an API key
  	req.params['authentication_token'].presence
  end

  throttle('req/ip', :limit => 2, :period => 5.minutes) do |req|
  	req.ip
  end
end