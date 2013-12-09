module Ingestor
  class Legacy
    class ErrorHandler

      def initialize(source_name)
        @source_name = source_name
        @logger = Logger.new(STDERR)
      end

      def handle(csv_row, ex)
        error_message = "(#{ex.class}) #{ex.message}: #{ex.backtrace.first}"

        logger.error "Error importing Notice #{csv_row['NoticeID']} from #{source_name}"
        logger.error "  Error: #{error_message}"
        logger.error "  Files: #{file_paths(csv_row)}"

        NoticeImportError.create!(
          original_notice_id: csv_row['NoticeID'].to_i,
          file_list: file_paths(csv_row),
          message: ex.message,
          stacktrace: ex.backtrace.first,
          import_set_name: source_name
        )
      rescue => ex
        logger.error "Failure handling failure: #{ex}"
      end

      private

      attr_reader :logger, :source_name

      def file_paths(csv_row)
        paths  = (csv_row['OriginalFilePath'] || '').split(',')
        paths += (csv_row['SupportingFilePath'] || '').split(',')
        paths.join(',')
      end

    end
  end
end
