RailsAdmin.config do |config|

  config.main_app_name = ['Chilling Effects', 'Admin']

  config.current_user_method { current_user }

  # TODO: Admin authorization
  # config.authorize_with do
  #   redirect_to '/', alert: "Not an admin" unless current_user.admin?
  # end

  # TODO: Model setup
  # For now, we'll just use the auto-introspected model metadata. See
  # https://github.com/sferik/rails_admin/wiki when we decide to
  # customize.

end
