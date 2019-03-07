class ApplicationMailer < ActionMailer::Base
  default from: Chill::Application.config.default_sender,
          return_path: Chill::Application.config.return_path,
          template_path: 'mailers'

  layout 'mailer'
end
