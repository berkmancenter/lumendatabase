require 'rake'

namespace :chillingeffects do

  desc 'Initialize staging app on heroku'
  task initialize_heroku: :environment do
    system("heroku pg:reset DATABASE_URL \
           --remote staging --confirm chillingeffects")
    system("heroku run rake db:migrate chillingeffects:delete_search_index \
           db:seed --remote staging")
  end

  desc 'Delete elasticsearch index'
  task delete_search_index: :environment do
    Tire.index('notices').delete
    sleep 5
  end

end
