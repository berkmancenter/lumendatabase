# frozen_string_literal: true

require 'rake'
require 'blog_importer'
require 'question_importer'
require 'collapses_topics'
require 'csv'

namespace :lumen do
  desc 'Delete elasticsearch index'
  task delete_search_index: :environment do
    Notice.__elasticsearch__.delete_index!
    sleep 5
  end

  desc 'Import blog entries'
  task import_blog_entries: :environment do
    with_file_name do |file_name|
      importer = BlogImporter.new(file_name)
      importer.import
    end
  end

  desc 'Import questions'
  task import_questions: :environment do
    with_file_name do |file_name|
      importer = QuestionImporter.new(file_name)
      importer.import
    end
  end

  desc 'Post-migration cleanup'
  task post_import_cleanup: :environment do
    from = 'DMCA Notices'
    to = 'DMCA Safe Harbor'
    collapser = CollapsesTopics.new(from, to)
    collapser.collapse
  end

  desc 'Incrementally index changed model instances'
  task index_changed_model_instances: :environment do
    ReindexRun.index_changed_model_instances
  end

  desc 'Update index for all existing hidden notices '
  task index_hidden_notices: :environment do
    # one-off script for existing hidden notices
    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where(hidden: true)
      Rails.logger.info 'index_notices hidden: true'

      count = 0
      notices.find_in_batches(batch_size: batch_size) do |batch|
        Notice.import batch
        count += batch.count
        Rails.logger.info "index_notices hidden: true, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      Rails.logger.info "index_notices done hidden: true, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      Rails.logger.error "index_notices hidden: true, error: #{e.inspect}"
    end
  end

  desc 'Index notices by csv'
  task :index_notices_by_csv, %i[input_csv id_column] => :environment do |_t, args|
    index_notices_by_csv args[:input_csv], args[:id_column]
  end

  def index_notices_by_csv(input_csv, id_column)
    usage = "index_notices_by_csv['input_csv,id_column']"

    if input_csv.nil? || id_column.nil?
      puts usage
      return
    end

    unless File.exist?(input_csv)
      puts 'Cannot find input_csv'
      puts usage
      return
    end

    batch_size = (ENV['BATCH_SIZE'] || 192).to_i

    csv = CSV.read input_csv, headers: true

    Rails.logger.info "index_notices csv: #{input_csv}, total: #{csv.count}"

    count = 0

    csv[id_column].each_slice(batch_size) do |ids|
      batch = Notice.where("id in ( #{ids.join ','} )")

      Notice.import batch
      count += batch.count
      Rails.logger.info "index_notices csv: #{input_csv}, count: #{count}, time: #{Time.now.to_i}"

      ReindexRun.sweep_search_result_caches

      Rails.logger.info "index_notices done csv: #{input_csv}, count: #{count}, time: #{Time.now.to_i}"
    end
  end

  desc 'Recreate elasticsearch index for notices with a given recipient entity_id'
  task :index_notices_by_entity_id, [:entity_id] => :environment do |_t, args|
    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where("id in ( select notice_id from entity_notice_roles where name = 'recipient' and entity_id = #{args[:entity_id]} )")
      Rails.logger.info "index_notices entity_id: #{args[:entity_id]}, total: #{notices.count}"

      count = 0
      notices.find_in_batches(batch_size: batch_size) do |batch|
        Notice.import batch
        count += batch.count
        Rails.logger.info "index_notices entity_id: #{args[:entity_id]}, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      Rails.logger.info "index_notices done entity_id: #{args[:entity_id]}, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      Rails.logger.error "index_notices entity_id: #{args[:entity_id]}, error: #{e.inspect}"
    end
  end

  desc 'Recreate elasticsearch index for notices of a given date'
  task :index_notices_by_date, [:date] => :environment do |_t, args|
    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where("created_at::date = '#{args[:date]}'")
      Rails.logger.info "index_notices date: #{args[:date]}, total: #{notices.count}"

      count = 0
      notices.find_in_batches(batch_size: batch_size) do |batch|
        Notice.import batch
        count += batch.count
        Rails.logger.info "index_notices date: #{args[:date]}, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      Rails.logger.info "index_notices done date: #{args[:date]}, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      Rails.logger.error "index_notices error date: #{args[:date]}, error: #{e.inspect}"
    end
  end

  desc 'Recreate elasticsearch index for notices of a given month'
  task :index_notices_by_month, [:month, :year] => :environment do |_t, args|
    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where("extract( year from created_at ) = #{args[:year]} and extract( month from created_at ) = #{args[ :month ]}")
      Rails.logger.info "index_notices date: #{args[:year]}-#{args[:month]}, total: #{notices.count}"

      count = 0
      notices.find_in_batches(batch_size: batch_size) do |batch|
        Notice.import batch
        count += batch.count
        Rails.logger.info "index_notices date: #{args[:year]}-#{args[:month]}, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      Rails.logger.info "index_notices done date: #{args[:year]}-#{args[:month]}, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      Rails.logger.error "index_notices date: #{args[:year]}-#{args[:month]}, error: #{e.inspect}"
    end
  end

  desc 'Recreate elasticsearch index for notices of a given year'
  task :index_notices_by_year, [:year] => :environment do |_t, args|
    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where("extract( year from created_at ) = #{args[:year]}")
      Rails.logger.info "index_notices date: #{args[:year]}, total: #{notices.count}"

      count = 0
      notices.find_in_batches(batch_size: batch_size) do |batch|
        Notice.import batch
        count += batch.count
        Rails.logger.info "index_notices date: #{args[:year]}, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      Rails.logger.info "index_notices done date: #{args[:year]}, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      Rails.logger.error "index_notices date: #{args[:year]}, error: #{e.inspect}"
    end
  end

  desc 'Recreate elasticsearch index memory efficiently'
  task recreate_elasticsearch_index: :environment do
    begin
      batch_size = (ENV['BATCH_SIZE'] || 100).to_i
      [Notice, Entity].each do |klass|
        klass.__elasticsearch__.create_index! force: true
        count = 0
        klass.find_in_batches(batch_size: batch_size) do |instances|
          GC.start
          instances.each do |instance|
            instance.__elasticsearch__.index_document
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

  desc 'Recreate elasticsearch index memory efficiently'
  task create_elasticsearch_index_for_updated_instances: :environment do
    begin
      batch_size = (ENV['BATCH_SIZE'] || 100).to_i
      from = Date.parse(ENV['from'], '%Y-%m-%d') if ENV['from']

      if from.nil?
        error = '"from" parameter is missing (correct format %Y-%m-%d)'
        puts error
        Rails.logger.error error

        return
      end

      [Notice, Entity].each do |klass|
        klass.__elasticsearch__.create_index!
        count = 0
        klass.where('updated_at > ?', from)
             .find_in_batches(batch_size: batch_size) do |instances|
          GC.start
          instances.each do |instance|
            instance.__elasticsearch__.index_document
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

  desc 'Assign titles to untitled notices'
  task title_untitled_notices: :environment do
    # Similar to NoticeSubmissionInitializer model
    def generic_title(notice)
      if notice.recipient_name.present?
        "#{notice.class.label} notice to #{notice.recipient_name}"
      else
        "#{notice.class.label} notice"
      end
    end

    begin
      untitled_notices = Notice.where(title: 'Untitled')

      $stdout.puts "Renaming #{untitled_notices.count} notices..."
      untitled_notices.each do |notice|
        new_title = generic_title(notice)
        notice.update_attribute(:title, new_title)
        $stdout.puts '.'
      end
    rescue => e
      $stderr.warn "Titling did not succeed because: #{e.inspect}"
    end
  end

  desc 'Hide notices by submission_id'
  task :hide_notices_by_sid, %i[input_csv sid_column] => :environment do |_t, args|
    hide_notices_by_sid args[:input_csv], args[:sid_column]
  end

  def hide_notices_by_sid(input_csv, sid_column)
    usage = "hide_notices_by_sid['input_csv,sid_column']"

    if input_csv.nil? || sid_column.nil?
      puts usage
      return
    end

    unless File.exist?(input_csv)
      puts 'Cannot find input_csv'
      puts usage
      return
    end

    total = 0
    successful = 0
    failed = 0
    CSV.foreach(input_csv, headers: true) do |row|
      total += 1
      begin
        sid = row[sid_column].to_i
        notice = Notice.find_by_submission_id sid
        notice.published = false
        notice.hidden = true
        notice.save!
        successful += 1
      rescue
        failed += 1
      end

      puts total if (total % 100).zero?
    end

    puts "total: #{total}, successful: #{successful}, failed: #{failed}"
  end

  desc 'Change incorrect notice type'
  task :change_incorrect_notice_type, [:input_csv] => :environment do |_t, args|
    incorrect_ids_file = args[:input_csv] || Rails.root.join('tmp', 'incorrect_ids.csv')
    incorrect_notice_ids = []
    incorrect_notice_id_type = {}
    CSV.foreach(incorrect_ids_file, headers: true) do |row|
      incorrect_notice_ids << row['id'].to_i
      incorrect_notice_id_type[row['id'].to_i] = row['type'].classify
    end

    incorrect_notices = Notice.where(id: incorrect_notice_ids)

    $stdout.puts "Changing #{incorrect_notices.count} notices..."
    incorrect_notices.each do |notice|
      old_type = notice.class.name.constantize
      new_type = incorrect_notice_id_type[notice.id].constantize
      notice.update_column(:type, new_type.name)
      notice = notice.becomes new_type
      notice.title = notice.title.sub(
        /^#{old_type.label} notice/,
        "#{new_type.label} notice"
      )
      notice.topic_assignments.delete_all
      notice.touch
      notice.save!
      $stdout.puts '.'
    end
  end

  desc 'Index non-indexed models'
  task index_non_indexed: :environment do
    begin
      $stdout.puts "Indexing #{Notice.count + Entity.count} instances..."
      [Notice, Entity].each do |klass|
        ids = klass.pluck(:id)
        ids.each do |id|
          if ReindexRun.indexed?(klass, id)
            puts "Skipping #{klass}, #{id}"
          else
            puts "Indexing #{klass}, #{id}"
            klass.find(id).__elasticsearch__.index_document
          end
          $stdout.puts '.'
        end
      end
    rescue => e
      $stderr.warn "Reindexing did not succeed because: #{e.inspect}"
    end
  end

  desc 'Redact and reindex works'
  task redact_and_reindex_works: :environment do
    # This is a one-time task to redact sensitive information from all existing
    # work descriptions. We only look at works before a certain date (shortly
    # after our deploy date for this feature) because anything after that date
    # will be auto_redacted as part of the save process.
    works = Work.where('updated_at < (?)', Date.new(2018, 12, 21))
                .order(:id)
                .limit(100_000)
    works.each do |work|
      # Make sure that updated_at changes, so we don't re-redact this work.
      work.touch
      work.save # calls auto_redact
    end

    # Works aren't directly indexed in ES; they're indexed as columns on Notice.
    # Therefore we need to reindex the associated notices in order to update
    # Elasticsearch entries. Changing the updated_at column on the associated
    # notices will force them to update the next time
    # index_changed_model_instances runs. This will happen automatically as
    # part of the before_save callback on Work.
  end

  desc 'Publish notices whose publication delay has expired'
  task publish_embargoed: :environment do
    Notice.where(published: false).each(&:set_published!)
  end

  def with_file_name
    if file_name == ENV['FILE_NAME']
      yield file_name
    else
      puts 'Please specify the file name via the FILE_NAME environment variable'
    end
  end

  desc 'Assign blank action_taken to Google notices'
  task blank_action_taken: :environment do
    ActiveRecord::Base.connection.execute %{
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

  desc 'Redact content in a single notice by id'
  task :redact_lr_legalother_single, [:notice_id] => :environment do |_t, args|
    begin
      notices = Notice.includes(
        works: %i[infringing_urls copyrighted_urls]
      ).where(
        id: args[:notice_id]
      )

      # even though there's only one notice,
      # we do this like redact_lr_legalother to check for issues in the script
      notices.find_in_batches do |group|
        group.each do |notice|
          next unless notice.sender.present?
          redactor = InstanceRedactor::EntityNameRedactor.new(notice.sender.name)
          notice.works.each do |work|
            work.update_attributes(
              description: redactor.redact(work.description)
            )
            work.infringing_urls.each do |iu|
              iu.update_attributes(url: redactor.redact(iu.url))
            end
            work.copyrighted_urls.each do |cu|
              cu.update_attributes(url: redactor.redact(cu.url))
            end
          end
        end
      end
    rescue => e
      $stderr.warn "reassigning did not succeed because: #{e.inspect}"
    end
  end

  desc 'Redact content in lr_legalother notices from Google'
  task redact_lr_legalother: :environment do
    begin
      entities = Entity.where("entities.name ilike '%Google%'")
      total = entities.count
      entities.each.with_index(1) do |e, i|
        notices = e.notices.includes(
          works: %i[infringing_urls copyrighted_urls]
        ).where(
          entity_notice_roles: { name: 'recipient' }
        ).where(
          type: 'Defamation'
        )

        $stdout.puts "Redacting #{[notices.count, 1].max} notice(s)..."

        notices.find_in_batches do |group|
          group.each do |notice|
            next unless notice.sender.present?
            redactor = InstanceRedactor::EntityNameRedactor.new(notice.sender.name)
            notice.works.each do |work|
              work.update_attributes(
                description: redactor.redact(work.description)
              )
              work.infringing_urls.each do |iu|
                iu.update_attributes(url: redactor.redact(iu.url))
              end
              work.copyrighted_urls.each do |cu|
                cu.update_attributes(url: redactor.redact(cu.url))
              end
              $stdout.puts '.'
            end
          end
        end
        p.finish unless p.finished?
      end
    rescue => e
      $stderr.warn "reassigning did not succeed because: #{e.inspect}"
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

  desc 'Reassign Dmca Notices to DMCA notices'
  task up_dmca_migration: :environment do
    Notice.where(type: 'Dmca').update_all(type: 'DMCA')
  end

  desc 'Reassign DMCA Notices to Dmca notices'
  task down_dmca_migration: :environment do
    Notice.where(type: 'DMCA').update_all(type: 'Dmca')
  end

  desc "Given a work, for every notice having that work: replace the notice's work with a new blank work"
  task :blank_work_notices_works, [:work_id] => :environment do |_t, args|
    blank_work_notices_works args[:work_id]
  end

  def blank_work_notices_works(work_id)
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

    work.notices.each { |n| puts "creating new empty work for notice: #{n.id}" }
  end

  desc 'Remove future dates from date_received and date_sent in notices'
  task remove_future_dates: :environment do
    Notice.update_all('date_received = NULL', 'date_received > CURRENT_DATE')
    Notice.update_all('date_sent = NULL', 'date_sent > CURRENT_DATE')
  end

  desc 'Remove kinds from Google notices'
  task remove_google_kinds: :environment do
    ActiveRecord::Base.connection.execute %{
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

  desc 'Re-assign Google recipient entities to the canonical Google and add tags'
  task reassign_and_tag_google_entities: :environment do
    google_entities = Entity.joins(:entity_notice_roles)
                            .where('entities.name ILIKE ? AND entity_notice_roles.name ILIKE ?',
                                   'Google [%]',
                                   'recipient')
                            .select('DISTINCT entities.*')
                            .all
    google_entities.each do |entity|
      entity.notices.each do |notice|
        notice.tag_list.add(entity['name'][/(?<=\[).+(?=\])/])
        notice.save!
      end
    end
    google_entity_ids = Entity.joins(:entity_notice_roles)
                              .where('entities.name ILIKE ? AND entity_notice_roles.name ILIKE ?',
                                     'Google [%]',
                                     'recipient')
                              .select('DISTINCT entities.*')
                              .pluck(:id)
    EntityNoticeRole.where(entity_id: google_entity_ids)
                    .update_all(entity_id: 1)
  end

  desc 'Re-assign Google recipients to the canonical Google'
  task reassign_google_entities: :environment do
    google_entities = Entity.select('id')
                            .where(name: ['Google', 'Google, Inc.',
                                          'GOOGLE INC.', 'google', 'Google Inc',
                                          'Google USA', 'google.com',
                                          'google, inc', 'google inc',
                                          'google inc.'])
                            .pluck(:id)
    google_entities.delete(1)
    EntityNoticeRole.where(entity_id: google_entities).update_all(entity_id: 1)
  end

  desc 'Re-assign Twitter recipients to the canonical Twitter'
  task reassign_twitter_entities: :environment do
    twitter_entities = Entity.select('id')
                             .where(name: ['twitter', 'Twitter',
                                           'Twitter, Inc.', 'Twitter Inc.',
                                           'Twitter. Inc.', 'Twitter,Inc.',
                                           'Twitter, Inc.',
                                           'Twitter International Company',
                                           'TWITTER, INC.', 'twitter.com',
                                           'Twitter Trust and Safety'])
                             .pluck(:id)
    twitter_entities.delete(447_642)
    EntityNoticeRole.where(entity_id: twitter_entities)
                    .update_all(entity_id: 447_642)
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

  # Prior to https://github.com/berkmancenter/lumendatabase/pull/470, we were
  # running the rails cache clear command every 20 minutes in prod via cron.
  # Cache clear is very aggressive; it does an rm -rf of the filesystem cache.
  # This could cause errors wherein Rails ensured the existence of a directory
  # in which to write a cached fragment - then we destroyed those directories
  # via cache clear - and then Rails attempted and failed to write to the
  # directory in https://github.com/rails/rails/blob/4-2-stable/activesupport/lib/active_support/core_ext/file/atomic.rb#L49 .
  # (This is called via the cache write stack.)
  # These errors showed up in our logs per
  # https://cyber.harvard.edu/projectmanagement/issues/14130 .
  # This command, instead of rm -rfing the entire cache directory, finds all
  # files and directories last accessed more than one hour ago and deletes
  # them. This should preserve two things we actually want to preserve:
  # 1) cached fragments in active use;
  # 2) directories and files just created as part of the cache key check and
  # atomic file write process linked above.
  # While we still run the cron every 20 minutes, the atime is somewhat longer
  # longer than this. Why? Because we're finding that there are big CPU spikes
  # every 20 minutes as we rebuild the cache. However, the expiry time for
  # fragments is generally longer than 20 minutes, and Notice content rarely
  # changes, so let's allow content to stick around longer.
  # (Not _too_ long, though, or we run out of disk space.)
  desc 'safer cache clear'
  task safer_cache_clear: :environment do
    # Go to cache dir;
    # clear out any files more than a day old;
    # remove empty directories;
    # dump stderr to logfiles so it stops emailing us.
    # (Everything in log/ should get autorotated on prod based on its logrotate
    # configuration.)
    cmd = "cd #{__dir__}/../../tmp/cache && " \
          "touch #{__dir__}/../../log/safer_cache_clear.log &&" \
          "find . -type f -amin +60 -delete 2>> #{__dir__}/../../log/safer_cache_clear.log && " \
          "find . -type d -empty -delete 2>> #{__dir__}/../../log/safer_cache_clear.log"
    system(cmd)
  end

  # One of our major users periodically fetches recent court order documents to
  # use in his research; this makes that easier for him.
  desc 'generate report of recent court order attachments'
  task generate_court_order_report: :environment do
    reporter = CourtOrderReporter.new
    reporter.report
  end

  # We have special maintenance start & end tasks so that we can toggle the
  # RAILS_SERVE_STATIC_FILES env as part of the process; we normally want this
  # to be false (it's Apache's responsibility), but it must be true for turnout
  # to find its stylesheets.
  desc 'maintenance start'
  task maintenance_start: :environment do
    ENV['RAILS_SERVE_STATIC_FILES'] = 'true'
    Rake::Task['maintenance:start'].invoke
    system('touch tmp/restart.txt')
  end

  desc 'maintenance end'
  task maintenance_end: :environment do
    ENV['RAILS_SERVE_STATIC_FILES'] = nil
    Rake::Task['maintenance:end'].invoke
    system('touch tmp/restart.txt')
  end

  desc 'Send notifications about file uploads updates'
  task send_file_uploads_notifications: :environment do
    date_time_task = proc { "[#{Time.now.strftime("%d/%m/%Y %H:%M:%S")}] [rake send_file_uploads_notifications]" }

    puts "#{date_time_task.call} Starting a new task run"

    if DocumentsUpdateNotificationNotice.all.empty?
      puts "#{date_time_task.call} No scheduled notifications, nothing to process"
    end

    DocumentsUpdateNotificationNotice.all.each do |doc_notification|
      puts "#{date_time_task.call} Starting processing notice ##{doc_notification.notice.id}"

      TokenUrl.where(
        notice: doc_notification.notice,
        documents_notification: true
      ).each do |token_url|
        next unless token_url.email.present?

        puts "#{date_time_task.call} Sending a notification about notice ##{doc_notification.notice.id} to #{token_url.email}"

        TokenUrlsMailer.notice_file_uploads_updates_notification(
          token_url.email, token_url, doc_notification.notice
        ).deliver_later

        token_url.update_attribute(:expiration_date, Time.now + 24.hours)
      end

      puts "#{date_time_task.call} Finishing processing notice ##{doc_notification.notice.id}"
    end

    DocumentsUpdateNotificationNotice.delete_all

    puts "#{date_time_task.call} Finishing the task"
  end
end

class CourtOrderReporter
  def report
    setup_directories
    initialize_info_file
    fetch_files
    write_files
    make_archive
    email_users
  end

  def setup_directories
    Rails.logger.info '[rake] Generating court order attachments report'

    @magic_dir = ENV['USER_CRON_MAGIC_DIR'] || 'usercron'
    @base_dir = Rails.root.join('public', @magic_dir)
    Dir.mkdir(@base_dir) unless Dir.exist?(@base_dir)

    @working_dir = Rails.root.join('public', @magic_dir, 'working')
    Dir.mkdir(@working_dir) unless Dir.exist?(@working_dir)
  end

  def initialize_info_file
    @info_filepath = File.join(@working_dir, 'info.txt')
    info_header = <<~HEREDOC
      The following notices (if any) have attached files which must be reviewed
      by Lumen staff before they can be released:
    HEREDOC

    File.write(@info_filepath, info_header)
  end

  def fetch_files
    @files = FileUpload.where(
      notice: CourtOrder.where('created_at > ?', 1.week.ago),
    )
  end

  def write_files
    @files.each do |f|
      if f.kind == 'supporting'
        copy_file_to_archive(f)
      else
        notify_about_unredacted_files(f)
      end
    end
  end

  def copy_file_to_archive(f)
    # The first and third params ensure the filename is useful; the second
    # ensures it is unique. Stripping spaces and punctuation prevents problems
    # with invalid filenames.
    evil = /[\s$'"#=\[\]!><|;{}()*?~&\\]/
    name = "#{f.notice_id}_#{f.id}_#{f.file_file_name}".gsub(evil, '')
    system("cp #{Shellwords.escape(f.file.path)} '#{File.join(@working_dir, name)}'")
  end

  def notify_about_unredacted_files(f)
    return if f.notice.file_uploads.where(kind: 'supporting').present?
    File.write(
      @info_filepath,
      Rails.application.routes.url_helpers.notice_url(
        f.notice,
        host: Rails.application.config.action_mailer.default_url_options[:host]
      ),
      mode: 'a'
    )
  end

  def make_archive
    Rails.logger.info '[rake] Making court order reports archive'
    @archive_filename = Date.today.iso8601
    system("tar -czvf #{File.join(@base_dir, @archive_filename)}.tar.gz -C #{@working_dir} .")
    system("rm -r #{@working_dir}")
  end

  def email_users
    unless (emails && defined? SMTP_SETTINGS)
      Rails.logger.warn '[rake] Missing email or SMTP_SETTINGS; not emailing court order report'
      exit
    end

    Rails.logger.info '[rake] Sending court order report email'

    emails.each do |email|
      email_single_user(email)
    end
  end

  def emails
    @emails ||= begin
      JSON.parse ENV['USER_CRON_EMAIL']   # list of emails
    rescue JSON::ParserError
      [ENV['USER_CRON_EMAIL']]            # single-email string, as 1-item list
    end
  end

  def email_single_user(email)
    Net::SMTP.start(SMTP_SETTINGS[:address]) do |smtp|
      smtp.send_message mailtext, 'no-reply@lumendatabase.org', email
    end
  end

  def mailtext
    @mailtext ||= <<~HEREDOC
        Subject: Latest email archive from Lumen

        The latest archive of Lumen court order files can be found at
        #{Chill::Application.config.site_host}/#{@magic_dir}/#{@archive_filename}.tar.gz.
    HEREDOC
  end
end
