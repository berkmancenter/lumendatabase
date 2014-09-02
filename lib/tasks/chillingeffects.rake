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

  desc "Import chillingeffects data from Mysql"
  task import_notices_via_mysql: :environment do
    name = ENV['IMPORT_NAME']
    base_directory = ENV['BASE_DIRECTORY']
    where_fragment = ENV['WHERE']

    unless name && base_directory && where_fragment
      puts "You need to give an IMPORT_NAME, BASE_DIRECTORY and WHERE fragment"
      puts "See IMPORTING.md for additional details about environment variables necessary to import via mysql"
      exit
    end

    record_source = Ingestor::Legacy::RecordSource::Mysql.new(
      where_fragment, name, base_directory
    )
    ingestor = Ingestor::Legacy.new(record_source)
    ingestor.import
  end

  desc "Import latest legacy chillingeffects data from Mysql"
  task import_new_notices_via_mysql: :environment do
    # Configure the record_source
    latest_original_notice_id = Notice.maximum(:original_notice_id).to_i
    name = "latest-from-#{latest_original_notice_id}"
    base_directory = ENV['BASE_DIRECTORY']

    record_source = Ingestor::Legacy::RecordSource::Mysql.new(
      "tNotice.NoticeID > #{latest_original_notice_id}", 
      name, base_directory
    )
    ingestor = Ingestor::Legacy.new(record_source)
    ingestor.import
  end
  
  desc "Import notice error legacy chillingeffects data from Mysql"
  task import_error_notices_via_mysql: :environment do
    # Configure the record_source
    error_original_notice_ids = NoticeImportError.pluck(:original_notice_id)
    name = "error_notices"
    base_directory = ENV['BASE_DIRECTORY']

    record_source = Ingestor::Legacy::RecordSource::Mysql.new(
      "tNotice.NoticeID IN (#{error_original_notice_ids})", 
      name, base_directory
    )
    ingestor = Ingestor::Legacy.new(record_source)
    ingestor.import
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

  desc "Incrementally index changed model instances"
  task index_changed_model_instances: :environment do
    ReindexRun.index_changed_model_instances
  end

  desc "Recreate elasticsearch index memory efficiently"
  task recreate_elasticsearch_index: :environment do
    batch_size = (ENV['BATCH_SIZE'] || 100).to_i
    [Notice, Entity].each do |klass|
      klass.index.delete
      klass.create_elasticsearch_index
      count = 0
      klass.find_in_batches(conditions: '1 = 1', batch_size: batch_size) do |instances|
        GC.start
        instances.each do |instance|
          instance.update_index
          count += 1
          print '.'
        end
        puts "#{count} #{klass} instances indexed at #{Time.now.to_i}"
      end
    end
  end

  def with_file_name
    if file_name = ENV['FILE_NAME']
      yield file_name
    else
      puts "Please specify the file name via the FILE_NAME environment variable"
    end
  end

end
