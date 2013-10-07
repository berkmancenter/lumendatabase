require 'ingestor'

module Ingestor
  class LegacyCsv
    attr_accessor :logger, :succeeded, :failed

    def self.open(file_path)
      new(file_path)
    end

    def initialize(file_path)
      @start_unixtime = Time.now.to_f

      @base_directory, @csv_file = File.split(file_path)

      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO unless ENV['DEBUG']

      @logger.debug { "Started at: #{@start_unixtime}, #{Time.now}" }

      @error_handler = ErrorHandler.new(base_directory, csv_file)
      @error_handler.copy_headers(file_path)

      @succeeded = 0
      @failed = 0
    end

    def import
      logger.info "Importing legacy CSV file: #{csv_file} in #{base_directory}"

      Dir.chdir(base_directory) do
        CSV.foreach(csv_file, headers: true) { |csv_row| import_row(csv_row) }
      end

      logger.info "Import complete. #{succeeded} record(s) created."
      logger.warn "#{failed} failure(s)" unless failed.zero?
    end

    private

    attr_reader :base_directory, :csv_file, :error_handler

    def import_row(csv_row)
      Dmca.transaction do
        mapper = AttributeMapper.new(csv_row.to_hash)

        if Notice.where(original_notice_id: csv_row['NoticeID']).present?
          next
        end

        attributes = mapper.mapped
        updated_at = attributes.delete(:updated_at)

        dmca = mapper.notice_type.create!(attributes)
        dmca.update_attributes(updated_at: updated_at)

        logger.debug { "Imported: #{attributes[:original_notice_id]} -> #{dmca.id}" }

        self.succeeded += 1
        if self.succeeded % 100 == 0
          now_unixtime = Time.now.to_f
          records_per_sec = self.succeeded / (now_unixtime - @start_unixtime)
          logger.debug { "#{self.succeeded} records at #{now_unixtime} | #{Time.now} |#{records_per_sec} records / sec" }
        end
      end
    rescue => ex
      self.failed += 1
      error_handler.handle(csv_row, ex)
    end
  end
end
