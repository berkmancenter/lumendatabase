Rails.application.config.after_initialize do
  if Rails.env.development?
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.add_footer = true
    Bullet.stacktrace_includes = ['lumendatabase/app', 'lumendatabase/lib']
    Bullet.stacktrace_excludes = ['catch_json_parsing_errors.rb']
  end
end
