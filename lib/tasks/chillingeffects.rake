require 'rake'

namespace :chillingeffects do

  desc 'Delete elasticsearch index'
  task delete_search_index: :environment do
    Notice.index.delete
    sleep 5
  end

end
