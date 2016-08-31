module Ingestor
  class Legacy
    class ErrorHandler

      def initialize(source_name)
        @source_name = source_name
        @logger = Rails.logger
      end

      def handle(csv_row, ex)
        error_message = "(#{ex.class}) #{ex.message}: #{ex.backtrace.first}"


        logger.error "legacy import error original_notice_id: #{csv_row['NoticeID']}, name: #{source_name}, message: \"#{error_message}\""
        logger.debug "legacy import error data: \"#{csv_row.inspect}\""

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
