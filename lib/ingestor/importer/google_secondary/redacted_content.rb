require 'ingestor/importer/google_secondary/issue_content'

module Ingestor
  module Importer
    module GoogleSecondary
      class RedactedContent < IssueContent
        EXPLAIN_PREAMBLE = "Please explain in as much detail as possible what factual statements at this URL you contend are false, or otherwise what it is about the page's content that is defamatory according to the laws in force in your country.\n"
        QUOTE_PREAMBLE = "Please quote the exact text from each URL that you believe is false or otherwise defamatory. If the allegedly infringing content is a picture or video, please provide a detailed description of the picture/video in question so that we may locate it on the URL in question.\n"

        delegate :redact, to: :redactor

        def initialize(file_path, description_start)
          super
          entity_name = yield content.dup
          @redactor = RedactsNotices::RedactsEntityName.new(entity_name)
        end

        def to_work
          super.tap do |work|
            work.description_original = work.description
            work.description = redact(work.description)
          end
        end

        def description
          s = super
          "#{quote}\n#{EXPLAIN_PREAMBLE if s}#{s}".strip
        end

        def quote
          if content.match(/legalother_quote[^:]*:(.+?)\n[a-z_]+:/m)
            QUOTE_PREAMBLE + $1.strip
          end
        end

        private

        attr_reader :redactor

        def extract_urls(string)
          super.map { |k| { url_original: k[:url], url: redact(URI.decode(k[:url])) } }
        end
      end
    end
  end
end
