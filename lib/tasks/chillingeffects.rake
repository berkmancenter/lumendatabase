require 'rake'
require 'blog_importer'
require 'question_importer'
require 'collapses_topics'
require 'csv'

namespace :chillingeffects do
  desc 'Delete elasticsearch index'
  task delete_search_index: :environment do
    Notice.index.delete
    sleep 5
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

  desc "Update index for all existing hidden notices "
  task index_hidden_notices: :environment do
    # one-off script for existing hidden notices
    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where( hidden: true )
      Rails.logger.info "index_notices hidden: true"
      
      count = 0
      notices.find_in_batches( batch_size: batch_size ) do |batch|
        Tire.index( Notice.index_name ).import batch
        count += batch.count
        Rails.logger.info "index_notices hidden: true, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      Rails.logger.info "index_notices done hidden: true, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      Rails.logger.error "index_notices hidden: true, error: #{e.inspect}"
    end
  end

  desc "Index notices by csv"
  task :index_notices_by_csv, [:input_csv, :id_column] => :environment do |t, args|
    index_notices_by_csv args[:input_csv], args[:id_column]
  end

  def index_notices_by_csv( input_csv, id_column )
    usage = "index_notices_by_csv['input_csv,id_column']"

    if input_csv.nil? || id_column.nil?
      puts usage
      return
    end

    if !File.exists?( input_csv )
      puts 'Cannot find input_csv'
      puts usage
      return
    end

    batch_size = (ENV['BATCH_SIZE'] || 192).to_i

    csv = CSV.read input_csv, headers: true
    
    Rails.logger.info "index_notices csv: #{input_csv}, total: #{csv.count}"

    count = 0

    csv[id_column].each_slice( batch_size ) { |ids|
      batch = Notice.where( "id in ( #{ ids.join ',' } )" )
      
      Tire.index( Notice.index_name ).import batch
      count += batch.count
      Rails.logger.info "index_notices csv: #{input_csv}, count: #{count}, time: #{Time.now.to_i}"

      ReindexRun.sweep_search_result_caches

      Rails.logger.info "index_notices done csv: #{input_csv}, count: #{count}, time: #{Time.now.to_i}"

    }
  end

  desc "Recreate elasticsearch index for notices with a given recipient entity_id"
  task :index_notices_by_entity_id, [ :entity_id ] => :environment do |t, args|
    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where( "id in ( select notice_id from entity_notice_roles where name = 'recipient' and entity_id = #{args[:entity_id]} )" )
      Rails.logger.info "index_notices entity_id: #{args[:entity_id]}, total: #{notices.count}"
      
      count = 0
      notices.find_in_batches( batch_size: batch_size ) do |batch|
        Tire.index( Notice.index_name ).import batch
        count += batch.count
        Rails.logger.info "index_notices entity_id: #{args[:entity_id]}, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      Rails.logger.info "index_notices done entity_id: #{args[:entity_id]}, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      Rails.logger.error "index_notices entity_id: #{args[:entity_id]}, error: #{e.inspect}"
    end
  end

  desc "Recreate elasticsearch index for notices of a given date"
  task :index_notices_by_date, [ :date ] => :environment do |t, args|
    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where( "created_at::date = '#{args[ :date ]}'" )
      Rails.logger.info "index_notices date: #{args[:date]}, total: #{notices.count}"
      
      count = 0
      notices.find_in_batches( batch_size: batch_size ) do |batch|
        Tire.index( Notice.index_name ).import batch
        count += batch.count
        Rails.logger.info "index_notices date: #{args[:date]}, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      Rails.logger.info "index_notices done date: #{args[:date]}, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      Rails.logger.error "index_notices error date: #{args[:date]}, error: #{e.inspect}"
    end
  end

  desc "Recreate elasticsearch index for notices of a given month"
  task :index_notices_by_month, [ :month, :year ] => :environment do |t, args|
    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where( "extract( year from created_at ) = #{args[ :year ]} and extract( month from created_at ) = #{args[ :month ]}" )
      Rails.logger.info "index_notices date: #{args[:year]}-#{args[:month]}, total: #{notices.count}"
      
      count = 0
      notices.find_in_batches( batch_size: batch_size ) do |batch|
        Tire.index( Notice.index_name ).import batch
        count += batch.count
        Rails.logger.info "index_notices date: #{args[:year]}-#{args[:month]}, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      Rails.logger.info "index_notices done date: #{args[:year]}-#{args[:month]}, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      Rails.logger.error "index_notices date: #{args[:year]}-#{args[:month]}, error: #{e.inspect}"
    end
  end

  desc "Recreate elasticsearch index for notices of a given year"
  task :index_notices_by_year, [ :year ] => :environment do |t, args|
    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where( "extract( year from created_at ) = #{args[ :year ]}" )
      Rails.logger.info "index_notices date: #{args[:year]}, total: #{notices.count}"
      
      count = 0
      notices.find_in_batches( batch_size: batch_size ) do |batch|
        Tire.index( Notice.index_name ).import batch
        count += batch.count
        Rails.logger.info "index_notices date: #{args[:year]}, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      Rails.logger.info "index_notices done date: #{args[:year]}, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      Rails.logger.error "index_notices date: #{args[:year]}, error: #{e.inspect}"
    end
  end

  desc "Recreate elasticsearch index memory efficiently"
  task recreate_elasticsearch_index: :environment do
  begin
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
          Rails.logger.info "#{count} #{klass} instances indexed at #{Time.now.to_i}"
        end
      end
      ReindexRun.sweep_search_result_caches
  rescue => e
    Rails.logger.error "Reindexing did not succeed because: #{e.inspect}"
    end
  end

  desc "Assign titles to untitled notices"
  task title_untitled_notices: :environment do

    # Similar to SubmitNotice model
    def generic_title(notice)
      if notice.recipient_name.present?
        "#{notice.class.label} notice to #{notice.recipient_name}"
      else
        "#{notice.class.label} notice"
      end
    end


  begin
    untitled_notices = Notice.where(title: 'Untitled')
    p = ProgressBar.create(
      title: "Renaming",
      total: untitled_notices.count,
      format: "%t: %B %P%% %E %c/%C %R/s"
    )

    untitled_notices.each do |notice|
      new_title = generic_title(notice)
      #puts %Q|Changing title of Notice #{notice.id} to "#{new_title}"|
      notice.update_attribute(:title, new_title)
      p.increment
    end
  rescue => e
    $stderr.puts "Titling did not succeed because: #{e.inspect}"
    end
  end
  
  desc "Hide notices by submission_id"
  task :hide_notices_by_sid, [:input_csv, :sid_column] => :environment do |t, args|
    hide_notices_by_sid args[:input_csv], args[:sid_column]
  end

  def hide_notices_by_sid( input_csv, sid_column )
    usage = "hide_notices_by_sid['input_csv,sid_column']"

    if input_csv.nil? || sid_column.nil?
      puts usage
      return
    end

    if !File.exists?( input_csv )
      puts 'Cannot find input_csv'
      puts usage
      return
    end

    total = 0
    successful = 0
    failed = 0
    CSV.foreach( input_csv, :headers => true) do |row|
      total += 1
      begin
        sid = row[sid_column].to_i
        notice = Notice.find_by_submission_id sid
        notice.published = false
        notice.hidden = true
        notice.save!
        successful += 1
      rescue
        #puts "Error processing #{row[sid_column]}"
        failed += 1
      end

      if (total % 100) == 0
        puts total
      end
    end

    puts "total: #{total}, successful: #{successful}, failed: #{failed}"
  end

  desc "Change incorrect notice type"
  task :change_incorrect_notice_type, [:input_csv] => :environment do |t, args|
    incorrect_ids_file = args[:input_csv] || Rails.root.join('tmp', 'incorrect_ids.csv')
    incorrect_notice_ids = Array.new
    incorrect_notice_id_type = Hash.new
    CSV.foreach(incorrect_ids_file, :headers => true) do |row|
      incorrect_notice_ids << row['id'].to_i
      incorrect_notice_id_type[row['id'].to_i] = row['type'].classify
    end
    
    incorrect_notices = Notice.where(:id => incorrect_notice_ids)
    p = ProgressBar.create(
      type: "Reassigning",
      total: incorrect_notices.count,
      format: "%t: %B %P%% %E %c/%C %R/s"
    )
    
    incorrect_notices.each do |notice|
      old_type = notice.class.name.constantize
      new_type = incorrect_notice_id_type[notice.id].constantize
      notice.update_column(:type, new_type.name) 
      notice = notice.becomes new_type
      notice.title = notice.title.sub(/^#{old_type.label} notice/, "#{new_type.label} notice")
      notice.topic_assignments.delete_all
      notice.touch
      notice.save!
      p.increment
    end
  end

  desc "Index non-indexed models"
  task index_non_indexed: :environment do
  begin
    require 'tire/http/clients/curb'
    Tire.configure { client Tire::HTTP::Client::Curb }
    p = ProgressBar.create(
      title: "Objects",
      total: (Notice.count + Entity.count),
      format: "%t: %B %P%% %E %c/%C %R/s"
    )
    [Notice, Entity].each do |klass|
      ids = klass.pluck(:id)
      ids.each do |id|
        unless ReindexRun.is_indexed?(klass, id)
          puts "Indexing #{klass}, #{id}"
          klass.find(id).update_index
        end
        p.increment
      end
    end
  rescue => e
    $stderr.puts "Reindexing did not succeed because: #{e.inspect}"
    end
  end

  desc "Publish notices whose publication delay has expired"
  task publish_embargoed: :environment do
    Notice.where(published: false).each do |notice|
      notice.set_published!
    end
  end

  def with_file_name
    if file_name = ENV['FILE_NAME']
      yield file_name
    else
      puts "Please specify the file name via the FILE_NAME environment variable"
    end
  end

  desc "Assign blank action_taken to Google notices"
  task blank_action_taken: :environment do
    ActiveRecord::Base.connection.execute %Q{
update notices
set action_taken = '',
  updated_at = now()
where notices.id in ( 
  select notices.id from notices
  inner join entity_notice_roles on entity_notice_roles.notice_id = notices.id and entity_notice_roles.name = 'recipient'
  and entity_notice_roles.entity_id in (select id from entities where entities.name ilike '%google%')
)
    }
  end

  desc "Redact content in a single notice by id"
  task :redact_lr_legalother_single, [ :notice_id ] => :environment do |t, args|
    begin
      notices = Notice.includes(
        works: [:infringing_urls, :copyrighted_urls]
      ).where(
        id: args[ :notice_id ]
      )

      # even though there's only one notice,
      # we do this like redact_lr_legalother to check for issues in the script
      notices.find_in_batches do |group|
        group.each do |notice|
          if notice.sender.present?
            redactor = RedactsNotices::RedactsEntityName.new(notice.sender.name)
            notice.works.each do |work|
              work.update_attributes(description: redactor.redact(work.description))
              work.infringing_urls.each do |iu|
                iu.update_attributes(url: redactor.redact(iu.url))
              end
              work.copyrighted_urls.each do |cu|
                cu.update_attributes(url: redactor.redact(cu.url))
              end
            end
          end
        end
      end
    rescue => e
      $stderr.puts "reassigning did not succeed because: #{e.inspect}"
    end
  end

  desc "Redact content in lr_legalother notices from Google"
  task redact_lr_legalother: :environment do

  begin
    entities = Entity.where("entities.name ilike '%Google%'")
    total = entities.count
    entities.each.with_index(1) do |e, i|
      notices = e.notices.includes(
        works: [:infringing_urls, :copyrighted_urls]
      ).where(
        entity_notice_roles: { name: 'recipient' }
      ).where(
        type: 'Defamation'
      )

      p = ProgressBar.create(
        title: "updating #{e.name} (#{i} of #{total})",
        total: ([notices.count, 1].max),
        format: "%t: %b %p%% %e %c/%c %r/s"
      )
      notices.find_in_batches do |group|
        group.each do |notice|
          if notice.sender.present?
            redactor = RedactsNotices::RedactsEntityName.new(notice.sender.name)
            notice.works.each do |work|
              work.update_attributes(description: redactor.redact(work.description))
              work.infringing_urls.each do |iu|
                iu.update_attributes(url: redactor.redact(iu.url))
              end
              work.copyrighted_urls.each do |cu|
                cu.update_attributes(url: redactor.redact(cu.url))
              end
              p.increment
            end
          end
        end
      end
      p.finish unless p.finished?
    end
  rescue => e
    $stderr.puts "reassigning did not succeed because: #{e.inspect}"
    end
  end

  desc "Print tallies of Notices with 'url_...' incorrectly tacked on to their subjects"
  task scrub_mangled_subjects: :environment do
    narrow = Notice.where("subject ~* '\\s*url_[a-z0-9]+:\\s*[a-z]*[:/]*[-?\\%.=&a-z/0-9]*$'").count
    puts "Narrow query: #{narrow}"
    broad = Notice.where("subject ~* '\\s*url_.*$'").count
    puts "Broad query: #{broad}"
    puts "Difference of: #{broad - narrow}"
  end

  desc "Reassign Dmca Notices to DMCA notices"
  task up_dmca_migration: :environment do
    Notice.where(type: 'Dmca').update_all(type: 'DMCA')
  end

  desc "Reassign DMCA Notices to Dmca notices"
  task down_dmca_migration: :environment do
    Notice.where(type: 'DMCA').update_all(type: 'Dmca')
  end

  desc "Given a work, for every notice having that work: replace the notice's work with a new blank work"
  task :blank_work_notices_works, [ :work_id ] => :environment do |t, args|
    blank_work_notices_works args[ :work_id ]
  end

  def blank_work_notices_works( work_id )
    usage = "usage: blank_work_notices_works['work_id']"

    if work_id.blank?
      puts usage
      return
    end

    work = Work.find_by id: work_id

    if work.nil?
      puts "cannot find work with id: #{work_id}"
      return
    end

    work.notices.each { |n|
      puts "creating new empty work for notice: #{n.id}"
    }
  end

  desc "Remove future dates from date_received and date_sent in notices"
  task remove_future_dates: :environment do
    Notice.update_all("date_received = NULL", "date_received > CURRENT_DATE")
    Notice.update_all("date_sent = NULL", "date_sent > CURRENT_DATE")
  end

  desc "Remove kinds from Google notices"
  task remove_google_kinds: :environment do
    ActiveRecord::Base.connection.execute %Q{
update works
set kind = 'Unspecified'
where works.id in (
  select works.id from works
  inner join notices_works on notices_works.work_id = works.id
  inner join notices on notices.id = notices_works.notice_id
  inner join entity_notice_roles on entity_notice_roles.notice_id = notices.id and entity_notice_roles.name = 'recipient'
  where entity_notice_roles.entity_id in (select id from entities where entities.name ilike '%google%')
  and not works.kind = 'Unspecified'
)
    }
  end

  desc "Re-assign Google recipient entities to the canonical Google and add tags"
  task reassign_and_tag_google_entities: :environment do
    google_entities = Entity.joins(:entity_notice_roles).where("entities.name ILIKE ? AND entity_notice_roles.name ILIKE ?", "Google [%]", "recipient").select("DISTINCT entities.*").all
    google_entities.each do |entity|
      entity.notices.each do |notice|
        notice.tag_list.add(entity["name"][/(?<=\[).+(?=\])/])
        notice.save!
      end
    end
    google_entity_ids = Entity.joins(:entity_notice_roles).where("entities.name ILIKE ? AND entity_notice_roles.name ILIKE ?", "Google [%]", "recipient").select("DISTINCT entities.*").pluck(:id)
    EntityNoticeRole.where(:entity_id => google_entity_ids).update_all(entity_id: 1)
  end

  desc "Re-assign Google recipients to the canonical Google"
  task reassign_google_entities: :environment do
    google_entities = Entity.select("id").where(:name => ["Google", "Google, Inc.", "GOOGLE INC.", "google", "Google Inc", "Google USA", "google.com", "google, inc", "google inc", "google inc."]).pluck(:id)
    google_entities - [1]
    EntityNoticeRole.where(:entity_id => google_entities).update_all(entity_id: 1)
  end

  desc "Re-assign Twitter recipients to the canonical Twitter"
  task reassign_twitter_entities: :environment do
    twitter_entities = Entity.select("id").where(:name => ["twitter", "Twitter", "Twitter, Inc.", "Twitter Inc.", "Twitter. Inc.", "Twitter,Inc.", "Twitter, Inc.", "Twitter International Company", "TWITTER, INC.", "twitter.com", "Twitter Trust and Safety"]).pluck(:id)
    twitter_entities - [447642]
    EntityNoticeRole.where(:entity_id => twitter_entities).update_all(entity_id: 447642)
  end
  
  desc 'Fix Google defamation notices in redact queue'
  task fix_google_redact_queue_notices: :environment do
    notices = Notice.where(title: 'Legal Complaint to Google',
                           type: 'Other',
                           hidden: true)
    notices.each do |notice|
      notice.body = notice.body_original[/(?:country\.)(.+)/, 1]
      notice.auto_redact
      notice.save!
    end
    notices.update_all(review_required: false)
  end

  desc 'Unhide hidden Google defamation notices'
  task unhide_google_defamation_notices: :environment do
    Notice.where(title: 'Legal Complaint to Google',
                 type: 'Other',
                 hidden: true)
          .update_all(hidden: false)
  end

  desc 'Remove Google API Defamation complaints from Redact Queue'
  task remove_google_api_redact_queue_notices: :environment do
    Notice.where(title: 'Defamation Complaint to Google', review_required: true)
          .update_all(review_required: false)
  end

end
