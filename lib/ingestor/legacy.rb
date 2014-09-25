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

      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO unless ENV['DEBUG']

      @logger.debug { "Started at: #{@start_unixtime}, #{Time.now}" }

      @error_handler = ErrorHandler.new(record_source.name)

      @succeeded = 0
      @failed = 0
    end

    def import(fail_import = false)
      logger.info "Importing legacy CSV file: #{record_source.name} in #{record_source.base_directory}"

      Dir.chdir(record_source.base_directory) do
        record_source.each do |csv_row|
          if Notice.where(original_notice_id: csv_row['NoticeID']).blank?
            if fail_import
              import_row(csv_row)
            else
              unless csv_row['Submitted_By'] == 'Google' && csv_row['add_date'] > Time.parse(ENV['LAUNCH_DATE'])
                import_row(csv_row)
              end   
            end  
          end
        end
      end

      logger.info "Import complete. #{succeeded} record(s) created."
      logger.warn "#{failed} failure(s)" unless failed.zero?
    end

    private

    attr_reader :error_handler, :record_source

    def import_row(csv_row)
      mapper = AttributeMapper.new(csv_row.to_hash)

      attributes = mapper.mapped

      dmca = mapper.notice_type.create!(attributes)

      logger.debug { "Imported: #{attributes[:original_notice_id]} -> #{dmca.id}" }
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
