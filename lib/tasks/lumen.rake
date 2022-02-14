# frozen_string_literal: true

require 'rake'
require 'collapses_topics'
require 'csv'
require 'comfy/blog_post_factory'
require 'loggy'
require 'court_order_reporter'
require 'yt_importer/yt_importer'
require 'fileutils'
require 'uri'

namespace :lumen do
  desc 'Delete elasticsearch index'
  task delete_search_index: :environment do
    Notice.__elasticsearch__.delete_index!
    sleep 5
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
    loggy = Loggy.new('rake lumen:index_hidden_notices', true)

    # one-off script for existing hidden notices
    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where(hidden: true)
      loggy.info 'index_notices hidden: true'

      count = 0
      notices.find_in_batches(batch_size: batch_size) do |batch|
        Notice.import batch
        count += batch.count
        loggy.info "index_notices hidden: true, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      loggy.info "index_notices done hidden: true, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      loggy.error "index_notices hidden: true, error: #{e.inspect}"
    end
  end

  desc 'Index notices by csv'
  task :index_notices_by_csv, %i[input_csv id_column] => :environment do |_t, args|
    index_notices_by_csv args[:input_csv], args[:id_column]
  end

  def index_notices_by_csv(input_csv, id_column)
    loggy = Loggy.new('rake lumen:index_notices_by_csv', true)

    usage = "index_notices_by_csv['input_csv,id_column']"

    if input_csv.nil? || id_column.nil?
      loggy.info usage
      return
    end

    unless File.exist?(input_csv)
      loggy.error 'Cannot find input_csv'
      loggy.error usage
      return
    end

    batch_size = (ENV['BATCH_SIZE'] || 192).to_i

    csv = CSV.read input_csv, headers: true

    loggy.info "index_notices csv: #{input_csv}, total: #{csv.count}"

    count = 0

    csv[id_column].each_slice(batch_size) do |ids|
      batch = Notice.where("id in ( #{ids.join ','} )")

      Notice.import batch
      count += batch.count
      loggy.info "index_notices csv: #{input_csv}, count: #{count}, time: #{Time.now.to_i}"

      ReindexRun.sweep_search_result_caches

      loggy.info "index_notices done csv: #{input_csv}, count: #{count}, time: #{Time.now.to_i}"
    end
  end

  desc 'Recreate elasticsearch index for notices with a given recipient entity_id'
  task :index_notices_by_entity_id, [:entity_id] => :environment do |_t, args|
    loggy = Loggy.new('rake lumen:index_notices_by_entity_id', true)

    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where("id in ( select notice_id from entity_notice_roles where name = 'recipient' and entity_id = #{args[:entity_id]} )")
      loggy.info "index_notices entity_id: #{args[:entity_id]}, total: #{notices.count}"

      count = 0
      notices.find_in_batches(batch_size: batch_size) do |batch|
        Notice.import batch
        count += batch.count
        loggy.info "index_notices entity_id: #{args[:entity_id]}, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      loggy.info "index_notices done entity_id: #{args[:entity_id]}, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      loggy.error "index_notices entity_id: #{args[:entity_id]}, error: #{e.inspect}"
    end
  end

  desc 'Recreate elasticsearch index for notices of a given date'
  task :index_notices_by_date, [:date] => :environment do |_t, args|
    loggy = Loggy.new('rake lumen:index_notices_by_date', true)

    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where("created_at::date = '#{args[:date]}'")
      loggy.info "index_notices date: #{args[:date]}, total: #{notices.count}"

      count = 0
      notices.find_in_batches(batch_size: batch_size) do |batch|
        Notice.import batch
        count += batch.count
        loggy.info "index_notices date: #{args[:date]}, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      loggy.info "index_notices done date: #{args[:date]}, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      loggy.error "index_notices error date: #{args[:date]}, error: #{e.inspect}"
    end
  end

  desc 'Recreate elasticsearch index for notices of a given month'
  task :index_notices_by_month, [:month, :year] => :environment do |_t, args|
    loggy = Loggy.new('rake lumen:index_notices_by_month', true)

    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where("extract( year from created_at ) = #{args[:year]} and extract( month from created_at ) = #{args[ :month ]}")
      loggy.info "index_notices date: #{args[:year]}-#{args[:month]}, total: #{notices.count}"

      count = 0
      notices.find_in_batches(batch_size: batch_size) do |batch|
        Notice.import batch
        count += batch.count
        loggy.info "index_notices date: #{args[:year]}-#{args[:month]}, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      loggy.info "index_notices done date: #{args[:year]}-#{args[:month]}, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      loggy.error "index_notices date: #{args[:year]}-#{args[:month]}, error: #{e.inspect}"
    end
  end

  desc 'Recreate elasticsearch index for notices of a given year'
  task :index_notices_by_year, [:year] => :environment do |_t, args|
    loggy = Loggy.new('rake lumen:index_notices_by_year', true)

    begin
      batch_size = (ENV['BATCH_SIZE'] || 192).to_i

      notices = Notice.where("extract( year from created_at ) = #{args[:year]}")
      loggy.info "index_notices date: #{args[:year]}, total: #{notices.count}"

      count = 0
      notices.find_in_batches(batch_size: batch_size) do |batch|
        Notice.import batch
        count += batch.count
        loggy.info "index_notices date: #{args[:year]}, count: #{count}, time: #{Time.now.to_i}"
      end

      ReindexRun.sweep_search_result_caches

      loggy.info "index_notices done date: #{args[:year]}, count: #{count}, time: #{Time.now.to_i}"
    rescue => e
      loggy.error "index_notices date: #{args[:year]}, error: #{e.inspect}"
    end
  end

  desc 'Recreate elasticsearch index memory efficiently'
  task recreate_elasticsearch_index: :environment do
    loggy = Loggy.new('rake lumen:recreate_elasticsearch_index', true)

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
            puts '.'
          end
          loggy.info "#{count} #{klass} instances indexed at #{Time.now.to_i}"
        end
      end
      ReindexRun.sweep_search_result_caches
    rescue => e
      loggy.error "Reindexing did not succeed because: #{e.inspect}"
    end
  end

  desc 'Recreate elasticsearch index memory efficiently'
  task create_elasticsearch_index_for_updated_instances: :environment do
    loggy = Loggy.new('rake lumen:create_elasticsearch_index_for_updated_instances', true)

    begin
      batch_size = (ENV['BATCH_SIZE'] || 100).to_i
      from = Date.parse(ENV['from'], '%Y-%m-%d') if ENV['from']

      if from.nil?
        error = '"from" parameter is missing (correct format %Y-%m-%d)'
        loggy.error error

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
            puts '.'
          end
          loggy.info "#{count} #{klass} instances indexed at #{Time.now.to_i}"
        end
      end
      ReindexRun.sweep_search_result_caches
    rescue => e
      loggy.error "Reindexing did not succeed because: #{e.inspect}"
    end
  end

  desc 'Assign titles to untitled notices'
  task title_untitled_notices: :environment do
    loggy = Loggy.new('rake lumen:title_untitled_notices', true)

    # Similar to NoticeBuilder model
    def generic_title(notice)
      if notice.recipient_name.present?
        "#{notice.class.label} notice to #{notice.recipient_name}"
      else
        "#{notice.class.label} notice"
      end
    end

    begin
      untitled_notices = Notice.where(title: 'Untitled')

      loggy.info "Renaming #{untitled_notices.count} notices..."
      untitled_notices.each do |notice|
        new_title = generic_title(notice)
        notice.update_attribute(:title, new_title)
        puts '.'
      end
    rescue => e
      loggy.warn "Titling did not succeed because: #{e.inspect}"
    end
  end

  desc 'Hide notices by submission_id'
  task :hide_notices_by_sid, %i[input_csv sid_column] => :environment do |_t, args|
    hide_notices_by_sid args[:input_csv], args[:sid_column]
  end

  def hide_notices_by_sid(input_csv, sid_column)
    loggy = Loggy.new('rake lumen:hide_notices_by_sid', true)

    usage = "hide_notices_by_sid['input_csv,sid_column']"

    if input_csv.nil? || sid_column.nil?
      loggy.info usage
      return
    end

    unless File.exist?(input_csv)
      loggy.error 'Cannot find input_csv'
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

      loggy.info total if (total % 100).zero?
    end

    loggy.info "total: #{total}, successful: #{successful}, failed: #{failed}"
  end

  desc 'Change incorrect notice type'
  task :change_incorrect_notice_type, [:input_csv] => :environment do |_t, args|
    loggy = Loggy.new('rake lumen:change_incorrect_notice_type', true)

    incorrect_ids_file = args[:input_csv] || Rails.root.join('tmp', 'incorrect_ids.csv')
    incorrect_notice_ids = []
    incorrect_notice_id_type = {}
    CSV.foreach(incorrect_ids_file, headers: true) do |row|
      incorrect_notice_ids << row['id'].to_i
      incorrect_notice_id_type[row['id'].to_i] = row['type'].classify
    end

    incorrect_notices = Notice.where(id: incorrect_notice_ids)

    loggy.info "Changing #{incorrect_notices.count} notices..."
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
      puts '.'
    end
  end

  desc 'Index non-indexed models'
  task index_non_indexed: :environment do
    loggy = Loggy.new('rake lumen:index_non_indexed', true)

    begin
      loggy.info "Indexing #{Notice.count} Notice instances..."
      # do notices
      Notice.includes(works: [:infringing_urls, :copyrighted_urls])
            .find_in_batches do |group|
        GC.start # force once per batch to avoid OOM
        group.each do |obj|
          puts '.'
          next if ReindexRun.indexed?(Notice, obj.id)

          loggy.info "Indexing Notice, #{obj.id}"
          obj.__elasticsearch__.index_document
        end
      end

      loggy.info "Indexing #{Entity.count} Entity instances..."
      Entity.find_in_batches do |group|
        group.each do |obj|
          puts '.'
          next if ReindexRun.indexed?(Entity, obj.id)

          loggy.info "Indexing Entity, #{obj.id}"
          obj.__elasticsearch__.index_document
        end
      end
    rescue => e
      loggy.info "Reindexing did not succeed because: #{e.inspect}"
    end
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
    loggy = Loggy.new('rake lumen:redact_lr_legalother_single', true)

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
            work.update(
              description: redactor.redact(work.description)
            )
            work.infringing_urls.each do |iu|
              iu.update(url: redactor.redact(iu.url))
            end
            work.copyrighted_urls.each do |cu|
              cu.update(url: redactor.redact(cu.url))
            end
          end
        end
      end
    rescue => e
      loggy.warn "reassigning did not succeed because: #{e.inspect}"
    end
  end

  desc 'Redact content in lr_legalother notices from Google'
  task redact_lr_legalother: :environment do
    loggy = Loggy.new('rake lumen:redact_lr_legalother', true)

    begin
      entities = Entity.where("entities.name ilike '%Google%'")
      entities.each.with_index(1) do |e, i|
        notices = e.notices.includes(
          works: %i[infringing_urls copyrighted_urls]
        ).where(
          entity_notice_roles: { name: 'recipient' }
        ).where(
          type: 'Defamation'
        )

        loggy.info "Redacting #{[notices.count, 1].max} notice(s)..."

        notices.find_in_batches do |group|
          group.each do |notice|
            next unless notice.sender.present?
            redactor = InstanceRedactor::EntityNameRedactor.new(notice.sender.name)
            notice.works.each do |work|
              work.update(
                description: redactor.redact(work.description)
              )
              work.infringing_urls.each do |iu|
                iu.update(url: redactor.redact(iu.url))
              end
              work.copyrighted_urls.each do |cu|
                cu.update(url: redactor.redact(cu.url))
              end
              puts '.'
            end
          end
        end
        p.finish unless p.finished?
      end
    rescue => e
      loggy.warn "reassigning did not succeed because: #{e.inspect}"
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
    loggy = Loggy.new('rake lumen:send_file_uploads_notifications', true)

    loggy.info 'Starting a new task run'

    if DocumentsUpdateNotificationNotice.all.empty?
      loggy.info 'No scheduled notifications, nothing to process'
    end

    DocumentsUpdateNotificationNotice.all.each do |doc_notification|
      loggy.info "Starting processing notice ##{doc_notification.notice.id}"

      TokenUrl.where(
        notice: doc_notification.notice,
        documents_notification: true
      ).each do |token_url|
        next unless token_url.email.present?

        loggy.info "Sending a notification about notice ##{doc_notification.notice.id} to #{token_url.email}"

        TokenUrlsMailer.notice_file_uploads_updates_notification(
          token_url.email, token_url, doc_notification.notice
        ).deliver_now

        token_url.update_attribute(:expiration_date, Time.now + LumenSetting.get_i('truncation_token_urls_active_period').seconds)
      end

      loggy.info "Finishing processing notice ##{doc_notification.notice.id}"
    end

    DocumentsUpdateNotificationNotice.delete_all

    loggy.info 'Finishing the task'
  end

  desc 'Set up CMS'
  task set_up_cms: :environment do
    if Comfy::Cms::Site.first.present?
      puts 'CMS already set up'
      # We don't want to mess with prod or dev data if they exist already, but
      # in test we need to repeatedly re-initialize the CMS in different
      # example groups.
      exit unless Rails.env.test?
    else
      Comfy::Cms::Site.create!(identifier: 'lumen_cms')
    end
    Rake::Task['comfy:cms_seeds:import'].execute(
      from: 'lumen_cms', to: 'lumen_cms'
    )
  end

  # There were also earlier tasks to migrate BlogEntry content to the CMS, but
  # they were removed upon removal of the BlogEntry model, after having been
  # run to migrate production content. They were last available in commit
  # b45018d.

  desc 'Run catchup ES indexing'
  task :run_catchup_es_indexing, %i[notices_index_name entities_index_name] => :environment do |_t, args|
    unless args[:notices_index_name].nil?
      types_to_set = [
        DMCA, Counterfeit, Counternotice, CourtOrder, DataProtection, Defamation,
        GovernmentRequest, LawEnforcementRequest, PrivateInformation, Trademark,
        Other
      ]
      types_to_set.each do |type_to_set|
        type_to_set.index_name args[:notices_index_name]
      end
    end

    unless args[:entities_index_name].nil?
      Entity.index_name args[:entities_index_name]
    end

    reindexing_timestamp_file = Rails.root.join('tmp', 'reindexing_timestamp')
    loggy = Loggy.new('rake lumen:run_catchup_es_indexing', true)

    unless File.exist?(reindexing_timestamp_file)
      loggy.info 'tmp/reindexing_timestamp file doesn\'t exist'
      exit
    end

    reindexing_start_date = File.mtime(reindexing_timestamp_file)
    # Get extra 10 minutes, just to make sure that everything is indexed
    reindexing_start_date -= 10.minutes
    batch_size = (ENV['BATCH_SIZE'] || 100).to_i
    number_of_all_items = Notice.where("updated_at > '#{reindexing_start_date}'").count + Entity.where("updated_at > '#{reindexing_start_date}'").count

    # Index updated and new entities
    begin
      count = 0
      [Notice, Entity].each do |klass|
        klass.where("updated_at > '#{reindexing_start_date}'").order('id ASC').find_in_batches(batch_size: batch_size) do |instances|
          # Force garbage collection to avoid OOM
          GC.start
          instances.each do |instance|
            instance.__elasticsearch__.index_document
            count += 1
            loggy.info(klass.name + ' indexing id ' + instance.id.to_s)
          end
          loggy.info(count.to_s + '/' + number_of_all_items.to_s + ' instances indexed')
        end
      end
      ReindexRun.sweep_search_result_caches
    rescue => e
      loggy.error('Reindexing did not succeed because: ' + e.inspect)
    end
  end

  desc 'Import YT notices'
  task import_yt_notices: :environment do
    loggy = Loggy.new('rake lumen:import_yt_notices', true, true)

    loggy.info('Starting importing YT notices from old chill')

    importer = YtImporter::YtImporter.new
    importer.import

    loggy.info('Finished importing YT notices from old chill')
  end

  desc 'Archive expired token urls'
  task archive_expired_token_urls: :environment do
    loggy = Loggy.new('rake lumen:archive_expired_token_urls', true)

    batch_size = 100

    TokenUrl.where(valid_forever: false).where('expiration_date < ?', Time.now).find_in_batches(batch_size: batch_size) do |token_urls|
      # Force garbage collection to avoid OOM
      GC.start
      token_urls.each do |token_url|
        ArchivedTokenUrl.create(token_url.attributes)
        token_url.destroy!

        loggy.info "Archived token url ##{token_url.id}"
      end
    end
  end

  desc 'Import media mendtions from csv'
  task :import_media_mentions_from_csv, [:input_csv] => :environment do |_t, args|
    input_csv = args[:input_csv]

    loggy = Loggy.new('rake lumen:import_media_mentions_from_csv', true)

    usage = "Use 'rake import_media_mentions_from_csv['input_csv_path']'"

    if input_csv.nil?
      loggy.info usage
      next
    end

    unless File.exist?(input_csv)
      loggy.error 'Cannot find input_csv'
      loggy.error usage
      next
    end

    new_mentions = []
    CSV.foreach(input_csv, headers: true) do |row|
      loggy.info "Importing '#{row['Title']}'"

      date = ''
      date = Date.strptime(row['Date'], '%m/%d/%Y') if row['Date'] if row['Date'] && row['Date'].count('/') == 2
      date = Date.strptime("01/#{row['Date']}", '%d/%m/%Y') if row['Date'] if row['Date'] && row['Date'].count('/') == 1
      date = Date.strptime("01/01/#{row['Date']}", '%m/%d/%Y') if row['Date'] if row['Date'] && row['Date'].length == 4

      new_mentions << {
        title: row['Title'],
        source: row['Source (or publisher for book)'],
        link_to_source: row['Link to Source'],
        scale_of_mention: row['Scale of mention'],
        date: date,
        document_type: row['Type'],
        comments: row['Comments'],
        published: true,
        author: row['Author']
      }
    end

    new_mentions.reverse!

    MediaMention.import new_mentions
  end

  desc 'Export gov requests'
  task export_gov_requests: :environment do
    loggy = Loggy.new('rake lumen:archive_expired_token_urls', true)

    batch_size = 100

    govs_dir = Rails.root.join('public')

    json_file = File.open("#{govs_dir}/notices.json", 'w+')

    json_file.write('[')

    i = 1
    GovernmentRequest.where('spam=false and hidden=false and published=true and rescinded=false').find_in_batches(batch_size: batch_size) do |notices|
      # Force garbage collection to avoid OOM
      GC.start
      notices.each do |notice|
        begin
          json_file.write(NoticeSerializerProxy.new(notice).to_json)
          json_file.write(',')

          supporting_docs = notice.file_uploads.where(kind: 'supporting')
          if supporting_docs.any?
            notice_dir = "#{govs_dir}/#{notice.id}"
            FileUtils.mkdir_p(notice_dir)
            supporting_docs.each do |file_upload|
              FileUtils.cp(file_upload.file.path, notice_dir)
            end
          end
        rescue StandardError => e
          puts "Rescued: #{e.inspect}"
        end

        loggy.info i.to_s
        i += 1
      end
    end

    json_file.write(']')

    json_file.close
  end

  desc 'Feed notices with empty works'
  task feed_notices_with_empty_works: :environment do
    loggy = Loggy.new('rake lumen:feed_notices_with_empty_works', true)

    batch_size = 100

    i = 0

    Notice.where('spam=false and hidden=false and published=true and rescinded=false').find_in_batches(batch_size: batch_size) do |notices|
      # Force garbage collection to avoid OOM
      GC.start
      notices.each do |notice|
        i += 1
        loggy.info "Processing #{notice.id} i:#{i}"

        begin
          next if notice.works.none?
          next if notice.file_uploads.none?
          next if notice.infringing_urls.any?
          next if notice.copyrighted_urls.any?

          urls = []
          notice.file_uploads.each do |file_upload|
            content = File.read(file_upload.file.path)
            if content.include? 'url_box'
              file_urls = content.scan(/^url_box:(.+?)\r\n/).flatten.select { |url_box_result| url_box_result.strip =~ URI::DEFAULT_PARSER.make_regexp }
              urls.concat file_urls
            end
          end

          urls.uniq!
          urls = urls.compact.collect(&:strip)

          if urls.any?
            loggy.info "Fixing #{notice.id} i:#{i}"
            new_infringing_urls = urls.map do |url|
              existing = InfringingUrl.where('url=? OR url_original=?', url, url).first
              existing || InfringingUrl.create!(url: url)
            end

            notice.works.first.infringing_urls = new_infringing_urls
            notice.save!
          end
        rescue StandardError => e
          loggy.error "Rescued: #{e.inspect}"
        end
      end
    end
  end

  desc 'Mark notices ready to reindex after relations update'
  task mark_notices_to_reindex_after_relations_update: :environment do
    loggy = Loggy.new('rake lumen:mark_notices_to_reindex_after_relations_update', true)

    batch_size = 100

    NoticeUpdateCall.where(status: 'new').each do |notice_update_call|
      next unless ['work', 'entity', 'topic'].include?(notice_update_call.caller_type)

      loggy.info "Processing NoticeUpdateCall id=#{notice_update_call.id}"

      notice_update_call.update_attribute(:status, 'working')

      loggy.info "Processing #{notice_update_call.caller_type} id=#{notice_update_call.caller_id}"

      related_object = notice_update_call.caller_type.classify.constantize.find(notice_update_call.caller_id)
      related_object.notices.find_in_batches(batch_size: batch_size) do |notices|
        notices.each do |notice|
          notice.touch
        end
      end

      notice_update_call.update_attribute(:status, 'finished')
    end
  end
end
