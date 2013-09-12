module Ingestor
  class LegacyCsv
    class ErrorHandler
      include FileUtils

      delegate :close, to: :csv

      def initialize(directory)
        @originals = File.expand_path(directory)
        @failures = "#{originals}-failures"

        mkdir_p @failures

        @csv = CSV.open(File.join(@failures, 'tNotice.csv'), 'wb')
        @logger = Logger.new(STDERR)
      end

      def copy_headers(file_path)
        headers = File.open(file_path, &:readline).chomp.split(',')

        csv << (headers + ['FailureMessage'])
      end

      def handle(csv_row, ex)
        error_message = "(#{ex.class}) #{ex.message}: #{ex.backtrace.first}"
        original_files = csv_row.fetch('OriginalFilePath', '').split(',')

        logger.error "Error importing Notice #{csv_row['NoticeID']}"
        logger.error "  Error: #{error_message}"
        logger.error "  Files: #{original_files.join(', ')}"

        csv << (csv_row.to_hash.values + [error_message])

        original_files.each { |file_path| store_file(file_path) }

      rescue => ex
        logger.error "Failure handling failure: #{ex}"
      end

      private

      attr_reader :originals, :failures, :csv, :logger

      def store_file(file_path)
        directory, _ = File.split(file_path)
        new_directory = File.join(failures, directory)

        mkdir_p new_directory

        cp file_path, new_directory
      end
    end
  end
end
