require 'ingestor/importer/google_secondary/issue_content'

module Ingestor
  module Importer
    module GoogleSecondary
      class RedactedContent < IssueContent
        OTHER_PREAMBLE = "Please explain in detail why you believe the content on the above URLs is unlawful, citing specific provisions of law wherever possible.\n"
        QUOTE_PREAMBLE = "In order to ensure specificity, please quote the exact text from each URL above that you believe infringes on your rights. If the allegedly infringing content is a picture or video, please provide a detailed description of the picture/video in question so that we may locate it on the URL in question.\n"

        def to_work
          super.tap do |work|
            work.description = redact(work.description)
          end
        end

        def description
          s = super
          "#{quote}\n#{OTHER_PREAMBLE if s}#{s}".strip
        end

        def quote
          if content.match(/legalother_quote[^:]*:(.+?)\n[a-z_]+:/m)
            QUOTE_PREAMBLE + $1.strip
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
            "(?:#{match.join('|')})(?:[^a-z]*(?:#{match.join('|')}))*"
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
