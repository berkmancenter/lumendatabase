if Rails.env.development? || ENV['LUMEN_USE_OINK'].present?
  Rails.application.middleware.use Oink::Middleware
end
