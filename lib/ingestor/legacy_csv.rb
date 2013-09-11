require 'ingestor'

module Ingestor
  class LegacyCsv
    attr_accessor :logger, :succeeded, :failed, :error_logger

    def self.open(file_path)
      new(file_path)
    end

    def initialize(file_path)
      @file_path = file_path

      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO unless ENV['DEBUG']

      @error_logger = Logger.new(STDERR)

      @succeeded = 0
      @failed = 0
    end

    def import
      directory, base = File.split(file_path)

      logger.info "Importing legacy CSV file: #{base} in #{directory}"

      Dir.chdir(directory) do
        CSV.foreach(base, headers: true) { |csv_row| import_row(csv_row) }
      end

      logger.info "Import complete. #{succeeded} record(s) created."
      logger.warn "#{failed} failure(s)" unless failed.zero?
    end

    private

    attr_reader :file_path

    def import_row(csv_row)
      mapper = AttributeMapper.new(csv_row.to_hash)

      attributes = mapper.mapped
      updated_at = attributes.delete(:updated_at)

      dmca = mapper.notice_type.create!(attributes)
      dmca.update_attributes(updated_at: updated_at)

      logger.debug { "Imported: #{attributes[:original_notice_id]} -> #{dmca.id}" }

      self.succeeded += 1
    rescue => ex
      log_exception(csv_row, ex)
      self.failed += 1
    end

    def log_exception(csv_row, ex)
      error_logger.error "Error importing Notice #{csv_row['NoticeID']}"
      error_logger.error "  (#{ex.class}) #{ex.message}: #{ex.backtrace.first}"
      error_logger.error "Files: #{csv_row['OriginalFilePath']}"
    end
  end
end
