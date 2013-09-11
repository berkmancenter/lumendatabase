require 'ingestor'

module Ingestor
  class LegacyCsv
    attr_accessor :logger, :succeeded, :failed

    def self.open(file_path)
      new(file_path)
    end

    def initialize(file_path)
      @file_path = file_path

      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO unless ENV['DEBUG']

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
      attributes ||= {}
      log_exception(csv_row['NoticeID'], ex)
      self.failed += 1
    end

    def log_exception(notice_id, ex)
      logger.error "Error importing Notice #{notice_id}"
      logger.error "  (#{ex.class}) #{ex.message}: #{ex.backtrace.first}"
    end
  end
end
