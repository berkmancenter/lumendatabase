Rails.application.config.to_prepare do
  RailsAdmin::ApplicationController.class_eval do
    before_action :reload_rails_admin

    def reload_rails_admin
      RailsAdmin::Config.reset

      load("#{Rails.root}/config/initializers/rails_admin.rb")
    end
  end
end
