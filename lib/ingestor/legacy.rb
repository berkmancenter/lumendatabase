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

      @logger.debug { "[importer][legacy] started: #{@start_unixtime}, #{Time.now}" }

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

      logger.info "[importer][legacy] name: #{record_source.name}, succeded: #{succeeded}, failed: #{failed}"
    end

    private

    attr_reader :error_handler, :record_source

    def import_row(csv_row)
      logger.debug "[importer][legacy] import_row NoticeID: #{csv_row['NoticeID']}"

      mapper = AttributeMapper.new(csv_row.to_hash)

      attributes = mapper.mapped
      logger.debug "[importer][legacy] body: #{attributes[ :body ]}"

      existing_notice = Notice.where(original_notice_id: csv_row['NoticeID'])
      logger.debug "[importer][legacy] existing_notice.count: #{existing_notice.count}"

      notice = nil

      if existing_notice.blank?
        logger.debug "[importer][legacy] import new notice"
        notice = mapper.notice_type.new(attributes)
      else
        logger.debug "[importer][legacy] reimport notice"
        notice = existing_notice.first
        notice.works.delete_all
        notice.reset_type =  mapper.notice_type.to_s
        notice.update_attributes(attributes)
      end

      logger.debug "[importer][legacy] notice.save: #{notice.inspect}"
      logger.debug "[importer][legacy] notice.save works: #{notice.works.inspect}"
      logger.debug "[importer][legacy] notice.save works[0].infringing_urls: #{notice.works.first.infringing_urls.inspect}"
      notice.save!

      logger.debug { "[importer][legacy] id: #{attributes[:original_notice_id]} -> #{notice.id}" }
      if error = NoticeImportError.find_by_original_notice_id(csv_row['NoticeID'])
        error.destroy
      end
      self.succeeded += 1

      if self.succeeded % 100 == 0
        now_unixtime = Time.now.to_f
        records_per_sec = self.succeeded / (now_unixtime - @start_unixtime)
        logger.debug { "[importer][legacy] #{self.succeeded} records at #{now_unixtime} | #{Time.now} |#{records_per_sec} records / sec" }
      end
    rescue => ex
      self.failed += 1
      error_handler.handle(csv_row, ex)
    end
  end
end
