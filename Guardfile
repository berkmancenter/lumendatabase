# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'spork', :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch('config/environments/test.rb')
  watch('config/routes.rb')
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch('spec/factories.rb')
  watch(%r{^lib/.+\.rb$})

  # These models are mentioned in initializers which prevents rails from
  # marking them for hot-reloading in development and test.
  watch('app/models/ability.rb')
  watch('app/models/notice.rb')
  watch('app/models/search_results_proxy.rb')
  watch('app/models/user.rb')
end
