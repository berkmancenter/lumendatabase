require 'rake'
require 'ingestor'
require 'blog_importer'
require 'question_importer'
require 'collapses_topics'

namespace :chillingeffects do
  desc 'Delete elasticsearch index'
  task delete_search_index: :environment do
    Notice.index.delete
    sleep 5
  end

  desc "Import legacy chillingeffects data"
  task import_legacy_data: :environment do
    with_file_name do |file_name|
      ingestor = Ingestor::LegacyCsv.open(file_name)
      ingestor.import
    end
  end

  desc "Import blog entries"
  task import_blog_entries: :environment do
    with_file_name do |file_name|
      importer = BlogImporter.new(file_name)
      importer.import
    end
  end

  desc "Import questions"
  task import_questions: :environment do
    with_file_name do |file_name|
      importer = QuestionImporter.new(file_name)
      importer.import
    end
  end

  desc "Post-migration cleanup"
  task post_import_cleanup: :environment do
    from = 'DMCA Notices'
    to = 'DMCA Safe Harbor'
    collapser = CollapsesTopics.new(from, to)
    collapser.collapse
  end

  def with_file_name
    if file_name = ENV['FILE_NAME']
      yield file_name
    else
      puts "Please specify the file name via the FILE_NAME environment variable"
    end
  end

end
