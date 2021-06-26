require 'loggy'
require 'mysql2'
require 'yt_importer/mapping/html/counterfeit'
require 'yt_importer/mapping/html/defamation'
require 'yt_importer/mapping/html/other_legal'
require 'yt_importer/mapping/html/trademark_d'
require 'yt_importer/mapping/plain_new/counterfeit'
require 'yt_importer/mapping/plain_new/defamation'
require 'yt_importer/mapping/plain_new/other_legal'
require 'yt_importer/mapping/plain_new/trademark_d'

module YtImporter
  class YtImporter
    FILES_DIRECTORY = ENV['BASE_DIRECTORY']
    IMPORT_FILE_BATCH_SIZE = 500
    READLEVELS = {
      '3' => :hidden,
      '8' => :hidden,
      '9' => :spam,
      '10' => :rescinded
    }.freeze

    def initialize
      @logger = Loggy.new('YtImporter', true)

      if FILES_DIRECTORY.nil?
        @logger.info('The BASE_DIRECTORY env variable must be set to continue')
        return
      end

      @number_to_import = 0
      @number_imported = 0
      @number_failed_imports = 0
    end

    def import
      create_new_yt_import_record
      generate_yt_files_list unless ENV['YT_IMPORT_SKIP_FILE_GENERATION']
      import_notices
    end

    private

    def create_new_yt_import_record
      YtImport.create
    end

    def import_date_from
      date = ENV['YT_IMPORT_DATE_FROM'] || YtImport&.last&.created_at&.in_time_zone('Eastern Time (US & Canada)')&.strftime('%Y-%m-%d %H:%M:%S') || '2000-01-01 00:00:00'

      " -newermt '#{date}'"
    end

    def import_date_to
      date = ENV['YT_IMPORT_DATE_TO']

      return " \! -newermt '#{date}'" if date

      ''
    end

    def import_files_list_file
      ENV['YT_IMPORT_FILES_LIST_FILE'] || 'tmp/yt_importer_files_list'
    end

    def generate_yt_files_list
      `touch #{import_files_list_file}`
      `find #{FILES_DIRECTORY} -type f #{import_date_from} #{import_date_to}  -exec grep -Rl 'youtube.com' {} + > #{import_files_list_file}`
    end

    def import_notices
      connect_to_legacy_database
      @number_to_import = `wc -l < #{import_files_list_file}`.strip.to_i
      @number_imported += 1

      File.open(import_files_list_file) do |file|
        file.each_slice(IMPORT_FILE_BATCH_SIZE) do |lines|
          lines.each do |file_to_process|
            import_single_notice(file_to_process.strip)

            # To avoid "Commands out of sync; you can't run this command now" errors
            @legacy_database_connection.abandon_results!
          end
        end
      end
    end

    def import_single_notice(file_to_process)
      @logger.info("Importing --- #{@number_imported + @number_failed_imports}/#{@number_to_import} --- file")
      @logger.info("Importing #{file_to_process}")

      if system("grep -q '<table' #{file_to_process}")
        format_class = 'Html'
      elsif system("grep -q '<HTML' #{file_to_process}") && !system("grep '<table' #{file_to_process}")
        format_class = 'PlainNew'
      else
        @number_failed_imports += 1
        return
      end

      file_data = read_file(file_to_process)

      mapper_class = nil
      mapper_class = "YtImporter::Mapping::#{format_class}::Counterfeit" if system("grep -q '<counterfeit\+' #{file_to_process}")
      mapper_class = "YtImporter::Mapping::#{format_class}::Defamation" if system("grep -q '<defamation\+' #{file_to_process}")
      mapper_class = "YtImporter::Mapping::#{format_class}::OtherLegal" if system("grep -q '<other-legal\+' #{file_to_process}")
      mapper_class = "YtImporter::Mapping::#{format_class}::TrademarkD" if system("grep -q '<trademark\+' #{file_to_process}")

      if mapper_class.nil?
        @number_failed_imports += 1
        single_notice_import_error(
          "Missing mapping type [#{file_to_process}]",
          file_to_process
        )
        return
      end

      if YoutubeImportFileLocation.where(path: file_to_process).any?
        @number_failed_imports += 1
        single_notice_import_error(
          "This notice was imported already in the past [#{file_to_process}]",
          file_to_process
        )
        return
      end

      mapped_notice_data = mapper_class.constantize.new(file_data, file_to_process)

      if mapped_notice_data.works.empty? ||
         mapped_notice_data.works.map(&:infringing_urls).flatten.empty?
        @number_failed_imports += 1
        single_notice_import_error(
          "Missing urls/works [#{file_to_process}]",
          file_to_process
        )
        return
      end

      data_from_legacy_database = get_file_data_from_legacy_database(file_to_process)

      file_creation_time = File.ctime(file_to_process)

      notice_params = {
        original_notice_id: data_from_legacy_database['NoticeID'],
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
        works: mapped_notice_data.works,
        review_required: false,
        topics: mapped_notice_data.topics,
        rescinded: rescinded?(data_from_legacy_database['ReadLevel']),
        hidden: hidden?(data_from_legacy_database['ReadLevel']),
        submission_id: data_from_legacy_database['SubmissionID'],
        entity_notice_roles: mapped_notice_data.entity_notice_roles,
        body: mapped_notice_data.body,
        body_original: mapped_notice_data.body_original,
        mark_registration_number: mapped_notice_data.mark_registration_number,
        jurisdiction_list: mapped_notice_data.jurisdiction,
        regulation_list: mapped_notice_data.regulation_list,
        language: mapped_notice_data.language,
        local_jurisdiction_laws: mapped_notice_data.local_jurisdiction_laws
      }

      new_notice = NoticeBuilder.new(
        mapped_notice_data.notice_type, notice_params
      ).build

      # Reject submitter and recipient, these roles will always be Youtube
      unless new_notice.entity_notice_roles
                       .reject { |entity_notice_role| %w[submitter recipient].include?(entity_notice_role.name) }
                       .any?
        @number_failed_imports += 1
        single_notice_import_error(
          "No entities found [#{file_to_process}]",
          file_to_process
        )
        return
      end

      new_notice.save!
      @number_imported += 1
    rescue StandardError, NameError => e
      @number_failed_imports += 1
      single_notice_import_error(
        "#{e.backtrace}: #{e.message} (#{e.class}) [#{file_to_process}]",
        file_to_process,
        "#{e.backtrace}: #{e.message} (#{e.class})"
      )
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
SELECT tNotice.NoticeID, tNotice.ReadLevel, rSub.sID AS SubmissionID
FROM tNotice
LEFT JOIN tNotImage all_documents
 ON all_documents.NoticeID = tNotice.NoticeID
LEFT JOIN rSubmit rSub
 ON tNotice.NoticeID=rSub.sID
WHERE all_documents.Location='#{file_path}'
GROUP BY tNotice.NoticeID
ORDER BY tNotice.NoticeID ASC
EOSQL
    end

    def read_file(file)
      content = IO.read(file)

      unless content.valid_encoding?
        content = content.unpack("C*").pack("U*")
      end

      content.gsub(/\r\n?/, "\n")
    end

    def single_notice_import_error(message, filename, stacktrace = '')
      @logger.error(message)
      YoutubeImportError.create(
        message: message,
        filename: filename,
        stacktrace: stacktrace
      )
    end

    def hidden?(readlevel)
      READLEVELS[readlevel] == :hidden
    end

    def rescinded?(readlevel)
      READLEVELS[readlevel] == :rescinded
    end
  end
end
