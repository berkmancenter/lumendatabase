if Rails.env.development? || ENV['USE_OINK'].present?
  Rails.application.middleware.use Oink::Middleware
end
