require 'loggy'
require 'mysql2'
require 'yt_importer/mapping/html/counterfeit'
require 'yt_importer/mapping/html/defamation'
require 'yt_importer/mapping/html/other_legal'
require 'yt_importer/mapping/html/trademark_d'

module YtImporter
  class YtImporter
    FILES_DIRECTORY = ENV['BASE_DIRECTORY']
    IMPORT_FILE_BATCH_SIZE = 500

    def initialize
      @logger = Loggy.new('YtImporter', true)

      if FILES_DIRECTORY.nil?
        @logger.info('The BASE_DIRECTORY env variable must be set to continue')
        return
      end

      @digested_files = []
      @number_to_import = 0
      @number_imported = 0
      @number_failed_imports = 0
    end

    def import
      create_new_yt_import_record
      generate_yt_files_list
      import_notices
    end

    private

    def create_new_yt_import_record
      YtImport.create
    end

    def import_date_from
      date = ENV['YT_IMPORT_DATE_FROM'] || YtImport&.last&.created_at&.strftime('%Y-%m-%d %H:%M:%S') || '2000-01-01 00:00:00'

      " -newermt '#{date}'"
    end

    def import_date_to
      date = ENV['YT_IMPORT_DATE_TO']

      return " \! -newermt '#{date}'" if date

      ''
    end

    def generate_yt_files_list
      `touch tmp/yt_importer_files_list`
      `find #{FILES_DIRECTORY} -type f #{import_date_from} #{import_date_to}  -exec grep -Rl 'youtube.com' {} + > tmp/yt_importer_files_list`
      @number_to_import = `wc -l < tmp/yt_importer_files_list`.strip.to_i
    end

    def import_notices
      connect_to_legacy_database

      @number_imported += 1

      File.open('tmp/yt_importer_files_list') do |file|
        file.each_slice(IMPORT_FILE_BATCH_SIZE) do |lines|
          lines.each do |file_to_process|
            import_single_notice(file_to_process.gsub('\n', ''))

            # To avoid "Commands out of sync; you can't run this command now" errors
            @legacy_database_connection.abandon_results!
          end
        end
      end
    end

    def import_single_notice(file_to_process)
      @logger.info("Importing #{@number_imported + @number_failed_imports}/#{@number_to_import} file")

      if system("grep 'Automatically added fields' #{file_to_process}")
        # digested_file_data = digest_plain_file(file_to_process)
        @number_failed_imports += 1
        @logger.info("Couldn't import #{file_to_process}, missing format")
        return
      elsif system("grep '<table' #{file_to_process}")
        format_class = 'Html'
        digested_file_data = digest_html_file(file_to_process)
      else
        @number_failed_imports += 1
        @logger.info("Couldn't import #{file_to_process}, missing format")
        return
      end

      mapper_class = nil
      mapper_class = "YtImporter::Mapping::#{format_class}::Counterfeit" if system("grep '<counterfeit\+' #{file_to_process}")
      mapper_class = "YtImporter::Mapping::#{format_class}::Defamation" if system("grep '<defamation\+' #{file_to_process}")
      mapper_class = "YtImporter::Mapping::#{format_class}::OtherLegal" if system("grep '<other-legal\+' #{file_to_process}")
      mapper_class = "YtImporter::Mapping::#{format_class}::TrademarkD" if system("grep '<trademark\+' #{file_to_process}")

      if mapper_class.nil?
        @number_failed_imports += 1
        @logger.info("Couldn't import #{file_to_process}, missing mapping type")
        return
      end

      data_from_legacy_database = get_file_data_from_legacy_database(file_to_process)

      legacy_notice_id = data_from_legacy_database['NoticeID']

      if Notice.where(original_notice_id: legacy_notice_id).any?
        @number_failed_imports += 1
        @logger.info("Couldn't import #{file_to_process}, this notice was imported already in the past")
        return
      end

      mapped_notice_data = mapper_class.constantize.new(digested_file_data, data_from_legacy_database, file_to_process)

      works = mapped_notice_data.works
      works = [Work.unknown] if works.empty?

      file_creation_time = File.ctime(file_to_process)

      new_notice = mapped_notice_data.notice_type.new({
        original_notice_id: legacy_notice_id,
        title: mapped_notice_data.title,
        subject: mapped_notice_data.subject,
        source: mapped_notice_data.source,
        tag_list: mapped_notice_data.tag_list,
        action_taken: mapped_notice_data.action_taken,
        created_at: file_creation_time,
        updated_at: file_creation_time,
        date_sent: file_creation_time,
        date_received: file_creation_time,
        file_uploads: mapped_notice_data.file_uploads,
        works: works,
        review_required: false,
        topics: mapped_notice_data.topics,
        rescinded: mapped_notice_data.rescinded?,
        hidden: mapped_notice_data.hidden?,
        submission_id: data_from_legacy_database['SubmissionID'],
        entity_notice_roles: mapped_notice_data.entity_notice_roles,
        body: mapped_notice_data.body,
        body_original: mapped_notice_data.body_original,
        mark_registration_number: mapped_notice_data.mark_registration_number
      })

      new_notice.save!
      @number_imported += 1
    rescue StandardError, NameError => e
      @number_failed_imports += 1
      @logger.info("Couldn't import #{file_to_process} #{e.backtrace}: #{e.message} (#{e.class})")
      YoutubeImportError.create(
        filename: file_to_process,
        stacktrace: "#{e.backtrace}: #{e.message} (#{e.class})",
        message: "Couldn't import #{file_to_process}"
      )
    end

    def digest_html_file(file)
      @logger.info("Digesting #{file}")
      read_file(file)
    end

    def connect_to_legacy_database
      @legacy_database_connection = Mysql2::Client.new(
        host: ENV['MYSQL_HOST'],
        username: ENV['MYSQL_USERNAME'],
        password: ENV['MYSQL_PASSWORD'],
        port: ENV['MYSQL_PORT'].to_i,
        database: ENV['MYSQL_DATABASE'],
        reconnect: true,
        read_timeout: 28800,
        connect_timeout: 28800
      )
    end

    def get_file_data_from_legacy_database(file_path)
      # Let's just get the file path part that is present in the database
      file_path_segments = file_path.split('/')
      db_file_path = "#{file_path_segments[7]}/#{file_path_segments[8]}/#{file_path_segments[9]}/#{file_path_segments[10]}/#{file_path_segments[11]}"
      result_row = nil
      results = @legacy_database_connection.query(legacy_database_query(db_file_path), stream: true, cache_rows: false)

      results.each do |row|
        result_row = row
      end

      result_row
    end

    def legacy_database_query(file_path)
return <<EOSQL
SELECT tNotice.NoticeID, tNotice.ReadLevel
FROM tNotice
LEFT JOIN tNotImage all_documents
 ON all_documents.NoticeID = tNotice.NoticeID
WHERE all_documents.Location='#{file_path}'
GROUP BY tNotice.NoticeID
ORDER BY tNotice.NoticeID ASC
EOSQL
    end

    def read_file(file)
      content = IO.read(file)
      if !content.valid_encoding?
        content.unpack("C*").pack("U*")
      else
        content
      end
    end
  end
end
