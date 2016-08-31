require 'ingestor'

module Ingestor
  class Legacy
    attr_accessor :logger, :succeeded, :failed, :record_source

    def self.open_csv(record_location)
      record_source = RecordSource::CSV.new(record_location)
      new(record_source)
    end

    def initialize(record_source)
      @record_source = record_source
      @start_unixtime = Time.now.to_f

      @logger = Rails.logger

      @logger.debug { "legacy import started: #{@start_unixtime}, #{Time.now}" }

      @error_handler = ErrorHandler.new(record_source.name)

      @succeeded = 0
      @failed = 0
    end

    def import
      Dir.chdir(record_source.base_directory) do
        record_source.each do |csv_row|
          import_row(csv_row)
        end
      end

      logger.info "legacy import name: #{record_source.name}, succeded: #{succeeded}, failed: #{failed}"
    end

    private

    attr_reader :error_handler, :record_source

    def import_row(csv_row)
      mapper = AttributeMapper.new(csv_row.to_hash)

      attributes = mapper.mapped

      notice = mapper.notice_type.create!(attributes)
      existing_notice = Notice.where(original_notice_id: csv_row['NoticeID'])
      logger.info "existing_notice.count: #{existing_notice.count}"
      if existing_notice.blank?
        notice = mapper.notice_type.create!(attributes)
      else
        notice = existing_notice.first
        notice.update_attributes(attributes)
      end

      logger.debug { "legacy import id: #{attributes[:original_notice_id]} -> #{notice.id}" }
      if error = NoticeImportError.find_by_original_notice_id(csv_row['NoticeID'])
        error.destroy
      end
      self.succeeded += 1

      if self.succeeded % 100 == 0
        now_unixtime = Time.now.to_f
        records_per_sec = self.succeeded / (now_unixtime - @start_unixtime)
        logger.debug { "#{self.succeeded} records at #{now_unixtime} | #{Time.now} |#{records_per_sec} records / sec" }
      end
    rescue => ex
      self.failed += 1
      error_handler.handle(csv_row, ex)
    end
  end
end
