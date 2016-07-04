secret_token = if Rails.env.development? or Rails.env.test?
  '56bf113ee241509bcf2d75a4d41191e09d7c4f12c7e47bf1437386a7c01518080f56d84a39db449fa5f24e5ded845410267d220fc54f750f876fb9ebc9d5e7c7'
else
  ENV['SECRET_TOKEN']
end

Chill::Application.config.secret_token = secret_token
