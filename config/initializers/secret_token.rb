# Technique Courtesy of:
# http://daniel.fone.net.nz/blog/2013/05/20/a-better-way-to-manage-the-rails-secret-token/

secret_token = if Rails.env.development? or Rails.env.test?
  ('x' * 30) # meets minimum requirement of 30 chars long
else
  ENV['SECRET_TOKEN']
end

Chill::Application.config.secret_token = secret_token
