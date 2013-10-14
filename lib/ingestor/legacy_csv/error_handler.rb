module Ingestor
  class LegacyCsv
    class ErrorHandler
      include FileUtils

      delegate :close, to: :csv

      def initialize(directory, file_name)
        @originals = File.expand_path(directory)
        @failures = "#{originals}-failures"
        @file_name = file_name

        mkdir_p @failures

        @csv = CSV.open(File.join(@failures, @file_name), 'wb')
        @logger = Logger.new(STDERR)
      end

      def copy_headers(file_path)
        headers = File.open(file_path, &:readline).chomp.split(',')

        csv << (headers + ['FailureMessage'])
      end

      def handle(csv_row, ex)
        file_paths  = (csv_row['OriginalFilePath'] || '').split(',')
        file_paths += (csv_row['SupportingFilePath'] || '').split(',')
        error_message = "(#{ex.class}) #{ex.message}: #{ex.backtrace.first}"

        logger.error "Error importing Notice #{csv_row['NoticeID']} from #{file_name}"
        logger.error "  Error: #{error_message}"
        logger.error "  Files: #{file_paths.join(', ')}"

        csv << (csv_row.to_hash.values + [error_message])

        file_paths.each { |file_path| store_file(file_path) }

      rescue => ex
        logger.error "Failure handling failure: #{ex}"
      end

      private

      attr_reader :originals, :failures, :csv, :logger, :file_name

      def store_file(file_path)
        directory, _ = File.split(file_path)
        new_directory = File.join(failures, directory)

        mkdir_p new_directory

        cp file_path, new_directory
      end
    end
  end
end
