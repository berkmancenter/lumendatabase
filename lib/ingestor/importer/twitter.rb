require 'ingestor/importer/base'

module Ingestor
  module Importer
    class Twitter < Base

      BODY_DIVIDER = '-------'
      WORK_DIVIDER = '---'

      handles_content(/^This email is a service from Twitter Support/)

      def parse_works(file_path)
        works = []

        file_handle = File.open(file_path)

        read_lines_until(file_handle, BODY_DIVIDER)
        read_lines_until(file_handle, BODY_DIVIDER) do
          works << parse_divided_work(file_handle)
        end

        works
      end

      def default_submitter
        'Twitter'
      end

      def default_recipient
        "Twitter"
      end

      private

      def parse_divided_work(file_handle)
        Work.new.tap do |work|
          read_lines_until(file_handle, WORK_DIVIDER) do |line|
            case line
            when /^== Description of original work: *(.*)/
              work.description = $1
            when /^== Reported Tweet URL: *(.*)/
              work.infringing_urls = [InfringingUrl.new(url: $1)]
            end
          end
        end
      end

      def read_lines_until(io, separator)
        loop do
          line = io.readline.chomp

          break if line == separator

          yield(line) if block_given?
        end
      rescue EOFError
      end

      private

      def sender(content)
        get_single_line_field(content, '== Name')
      end

      def principal(content)
        get_single_line_field(content, '== Copyright owner')
      end
    end

  end
end
