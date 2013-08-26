require 'rake'
require 'ingestor'

namespace :chillingeffects do
  desc 'Delete elasticsearch index'
  task delete_search_index: :environment do
    Notice.index.delete
    sleep 5
  end

  desc "Import legacy chillingeffects data"
  task import_legacy_data: :environment do
    if file_name = ENV['FILE_NAME']
      ingestor = Ingestor::LegacyCsv.open(file_name)
      ingestor.import
    else
      puts "Please specify the file name via the FILE_NAME environment variable"
    end
  end
end
