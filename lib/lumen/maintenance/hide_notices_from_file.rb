# frozen_string_literal: true

module Lumen
  module Maintenance
    class HideNoticesFromFile
      DEFAULT_BATCH_SIZE = 5_000
      MAX_INTEGER_ID = 2_147_483_647
      INVALID_LINE_SAMPLE_LIMIT = 20
      NOTICE_CGI_PATTERN = %r{
        \A
        (?:https?://[^/\s]+)?
        (?:/[^\s/?\#]+)*/?
        notice\.cgi\?
        (?<query>[^\#\s]+)
        (?:\#\S*)?
        \z
      }ix

      attr_reader :hidden_count, :invalid_count, :processed_count

      def initialize(path:, batch_size: DEFAULT_BATCH_SIZE, dry_run: false, output: $stdout)
        @path = Pathname.new(path)
        @batch_size = Integer(batch_size)
        @dry_run = dry_run
        @output = output
        @hidden_count = 0
        @invalid_count = 0
        @processed_count = 0

        raise ArgumentError, 'batch_size must be greater than zero' unless @batch_size.positive?
      end

      def call
        raise ArgumentError, "Cannot find input file: #{@path}" unless @path.file?

        File.foreach(@path).each_slice(@batch_size).with_index(1) do |lines, batch_number|
          hide_batch(lines)
          report_progress(batch_number)
        end

        report_summary
        self
      end

      private

      def hide_batch(lines)
        notice_ids = []
        submission_ids = []

        lines.each do |line|
          @processed_count += 1

          case parse_reference(line)
          in [:id, Integer => id]
            notice_ids << id
          in [:submission_id, Integer => id]
            submission_ids << id
          else
            report_invalid_line(line)
          end
        end

        @hidden_count += hide_by(:id, notice_ids.uniq)
        @hidden_count += hide_by(:submission_id, submission_ids.uniq)
      end

      def parse_reference(line)
        reference = line.strip

        if reference.match?(/\A\d+\z/)
          id = reference.to_i
          return [:id, id] if valid_id?(id)

          return nil
        end

        match = NOTICE_CGI_PATTERN.match(reference)
        return unless match

        sid_parameter = match[:query].split('&').find { |parameter| parameter.start_with?('sID=') }
        return unless sid_parameter&.match?(/\AsID=\d+\z/)

        id = sid_parameter.delete_prefix('sID=').to_i
        [:submission_id, id] if valid_id?(id)
      end

      def valid_id?(id)
        id.between?(1, MAX_INTEGER_ID)
      end

      def hide_by(column, ids)
        return 0 if ids.empty?

        relation = Notice.where(column => ids, hidden: false)
        return relation.count if @dry_run

        relation.update_all(hidden: true, updated_at: Time.current)
      end

      def report_invalid_line(line)
        @invalid_count += 1
        return if @invalid_count > INVALID_LINE_SAMPLE_LIMIT

        @output.puts "Invalid line #{@processed_count}: #{line.chomp.inspect}"
      end

      def report_progress(batch_number)
        verb = @dry_run ? 'would hide' : 'hidden'
        @output.puts(
          "Batch #{batch_number}: processed #{@processed_count}, #{verb} #{@hidden_count}, " \
          "invalid #{@invalid_count}"
        )
      end

      def report_summary
        verb = @dry_run ? 'would hide' : 'newly hidden'
        @output.puts(
          "Done: processed #{@processed_count}, #{verb} #{@hidden_count}, invalid #{@invalid_count}"
        )
      end
    end
  end
end
