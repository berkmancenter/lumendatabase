require 'uri'

module Ingestor
  module Importer
    class GoogleSecondary < Base
      class OtherParser

        def self.handles?(content)
          content.match(/IssueType:\s?lr_legalother2/m)
        end

        def initialize(content)
          @content = content
        end

        def description
          content.match(/legalother_explain[^:]*:(.+?)\nlegalother_quote[^:]*:/m)
          $1.strip
        end

        def copyrighted_urls
          extract_urls(description)
        end

        def infringing_urls
          content.match(/url_box[\d_]+:(.+?)\n\n/m)
          extract_urls($1)
        end

        private

        attr_reader :content

        def extract_urls(string)
          URI::extract(string).find_all { |url| url.match(/\Ahttps?/i) }
        end

      end
    end
  end
end
