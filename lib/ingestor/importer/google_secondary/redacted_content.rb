require 'ingestor/importer/google_secondary/issue_content'

module Ingestor
  module Importer
    module GoogleSecondary
      class RedactedContent < IssueContent
        def to_work
          super.tap do |work|
            work.description = redact(work.description)
          end
        end

        private

        attr_reader :name_regex

        def extract_urls(string)
          super.map { |k| { url: redact(k[:url]) } }
        end

        def name_regex
          @name_regex ||= extract_name_regex
        end

        def extract_name_regex
          if content.match(/full_name[^:]*:(.+?)\n[a-z_]+:/m)
            match = $1.strip.split(/\s/)
            ([match.join('[^a-z]+?')] << match).join('|')
          end
        end

        def redact(string)
          return string if name_regex.blank?
          string.gsub(/#{name_regex}/mi, '[REDACTED]')
        end
      end
    end
  end
end
