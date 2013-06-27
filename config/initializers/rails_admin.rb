RailsAdmin.config do |config|

  config.main_app_name = ['Chilling Effects', 'Admin']

  config.current_user_method { current_user }

  # TODO: Admin authorization
  # config.authorize_with do
  #   redirect_to '/', alert: "Not an admin" unless current_user.admin?
  # end

  config.model 'Notice' do
    edit do
      configure(:categorizations) { hide }
      configure(:blog_categorizations) { hide }
      configure(:category_relevant_questions) { hide }
      configure(:entities) { hide }
      configure(:infringing_urls) { hide }
    end
  end

  config.model 'EntityNoticeRole' do
    edit do
      configure(:notice) { hide }
    end
  end

  config.model 'Entity' do
    edit do
      configure(:notices) { hide }
      configure(:entity_notice_roles) { hide }
    end
  end

  config.model 'RelevantQuestion' do
    object_label_method { :question }
  end

  config.model 'Work' do
    object_label_method { :description }

    edit do
      configure(:notices) { hide }
    end
  end

  config.model 'InfringingUrl' do
    object_label_method { :url }
  end

end
