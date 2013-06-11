require 'rake'

namespace :chillingeffects do

  desc 'Delete elasticsearch index'
  task delete_search_index: :environment do
    Tire.index('notices').delete
    sleep 5
  end

end
