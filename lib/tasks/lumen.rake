# frozen_string_literal: true

require 'collapses_topics'
require 'csv'
require 'comfy/blog_post_factory'
require 'loggy'
require 'court_order_reporter'
require 'youtube_importer/youtube_importer'
require 'github_importer/github_importer'
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

      CacheSweeper.sweep_search_result_caches

      loggy.info "index_notices done hidden: true, count: #{count}, time: #{Time.now.to_i}"
    rescue StandardError => e
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

      CacheSweeper.sweep_search_result_caches

      loggy.info "index_notices done csv: #{input_csv}, count: #{count}, time: #{Time.now.to_i}"
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
    rescue StandardError => e
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
      rescue StandardError
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

          redactor = Redactors::EntityNameRedactor.new(notice.sender.name)
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
    rescue StandardError => e
      loggy.warn "reassigning did not succeed because: #{e.inspect}"
    end
  end

  desc 'Redact content in lr_legalother notices from Google'
  task redact_lr_legalother: :environment do
    loggy = Loggy.new('rake lumen:redact_lr_legalother', true)

    begin
      entities = Entity.where("entities.name ilike '%Google%'")
      entities.each.with_index(1) do |e, _i|
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

            redactor = Redactors::EntityNameRedactor.new(notice.sender.name)
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
    rescue StandardError => e
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

    loggy.info 'No scheduled notifications, nothing to process' if DocumentsUpdateNotificationNotice.where(status: 0).empty?

    DocumentsUpdateNotificationNotice.where(status: 0).each do |doc_notification|
      notice = doc_notification.notice

      loggy.info "Starting processing notice ##{notice.id}"

      DocumentNotificationEmail.where(
        notice: notice,
        status: 1,
      ).each do |document_notification_email|
        loggy.info "Sending a notification about notice #{notice.id} to #{document_notification_email.email_address}"

        DocumentNotificationsMailer.notice_file_uploads_updates_notification(
          document_notification_email.email_address,
          notice,
          document_notification_email,
        ).deliver_later
      end

      doc_notification.update(status: 1)

      loggy.info "Finishing processing notice ##{doc_notification.notice.id}"
    end

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

  desc 'Import YT notices'
  task import_yt_notices: :environment do
    loggy = Loggy.new('rake lumen:import_yt_notices', true, true)

    loggy.info('Starting importing YT notices from old chill')

    importer = YoutubeImporter::YoutubeImporter.new
    importer.import

    loggy.info('Finished importing YT notices from old chill')
  end

  # A cron job to fetch any new notices from the Github DMCA public repo
  desc 'Import Github notices'
  task import_github_notices: :environment do
    loggy = Loggy.new('rake lumen:import_github_notices', true, true)

    loggy.info('Starting import of Github notices from DMCA repo')

    importer = GithubImporter::GithubImporter.new
    importer.import

    loggy.info('Finished import of Github notices from DMCA repo')
  end

  desc 'Archive expired token urls'
  task archive_expired_token_urls: :environment do
    loggy = Loggy.new('rake lumen:archive_expired_token_urls', true)

    batch_size = 100

    TokenUrl.where(valid_forever: false).where('expiration_date < ?',
                                               Time.now).find_in_batches(batch_size: batch_size) do |token_urls|
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
      date = Date.strptime(row['Date'], '%m/%d/%Y') if row['Date'] && row['Date'].count('/') == 2 && (row['Date'])
      if row['Date'] && row['Date'].count('/') == 1 && (row['Date'])
        date = Date.strptime("01/#{row['Date']}", '%d/%m/%Y')
      end
      if row['Date'] && row['Date'].length == 4 && (row['Date'])
        date = Date.strptime("01/01/#{row['Date']}", '%m/%d/%Y')
      end

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
            next unless content.include? 'url_box'

            file_urls = content.scan(/^url_box:(.+?)\r\n/).flatten.select do |url_box_result|
              url_box_result.strip =~ URI::DEFAULT_PARSER.make_regexp
            end
            urls.concat file_urls
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
      next unless %w[work entity topic].include?(notice_update_call.caller_type)

      loggy.info "Processing NoticeUpdateCall id=#{notice_update_call.id}"

      notice_update_call.update_attribute(:status, 'working')

      loggy.info "Processing #{notice_update_call.caller_type} id=#{notice_update_call.caller_id}"

      related_object = notice_update_call.caller_type.classify.constantize.find_by(id: notice_update_call.caller_id)
      number_of_notices = related_object.notices.group(:id).count
      if related_object.present?
        loggy.info "Processing #{notice_update_call.caller_type} id=#{notice_update_call.caller_id} #{number_of_notices} items to process"

        itx = 1
        related_object.notices.group(:id).find_in_batches(batch_size: batch_size) do |notices|
          ProxyCache.clear_notice(notices.map(&:id))

          notices.each do |notice|
            loggy.info "Processing #{notice_update_call.caller_type} id=#{notice_update_call.caller_id} #{itx}/#{number_of_notices}"
            notice.touch
            itx += 1
          end
        end
      end

      notice_update_call.update_attribute(:status, 'finished')
    end
  end

  desc 'Merge entities with similar name and metadata'
  task merge_similar_entities: :environment do |_t|
    loggy = Loggy.new('rake lumen:merge_similar_entities', true)
    entities_to_merge_in = Entity.where("id IN (#{ENV['ENTITIES_TO_MERGE']})")
    entities_ids_to_skip = ENV['ENTITIES_TO_SKIP'] || ''
    entities_ids_to_skip = entities_ids_to_skip.split(',').map(&:to_i)

    entities_to_merge_in.each do |entity_to_merge_in|
      search_name = ENV['SEARCH_NAME'] || entity_to_merge_in.name

      entities_to_merge = if ENV['SEARCH_EXACT']
                            Entity.where("name ILIKE '%#{search_name}%'")
                          else
                            Entity.where('name = ?', search_name)
                          end

      entities_to_merge = entities_to_merge.where("id != #{entity_to_merge_in.id}")

      entities_to_merge.each do |entity_to_merge|
        next if entities_ids_to_skip.include?(entity_to_merge.id)

        loggy.info "Merging [#{entity_to_merge.name}] [#{entity_to_merge.id}] into [#{entity_to_merge_in.name}] [#{entity_to_merge_in.id}]"

        next if ENV['DRY_RUN']

        ActiveRecord::Base.connection.execute("
          UPDATE
            entity_notice_roles
          SET
            entity_id=#{entity_to_merge_in.id}
          WHERE
            entity_id=#{entity_to_merge.id}
        ")

        ActiveRecord::Base.connection.execute("
          DELETE
            from entities
          WHERE id=#{entity_to_merge.id}
        ")
      end
    end
  end
end
