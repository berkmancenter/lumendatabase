require 'uri'

module Ingestor
  module Importer
    class GoogleSecondary
      class DmcaParser

        def self.handles?(content)
          content.match(/IssueType:\s?lr_dmca/m)
        end

        def initialize(content)
          @content = content
        end

        def description
          content.match(/description_of_copyrighted_work:(.+?)\nfull_name:/m)
          $1.strip
        end

        def copyrighted_urls
          extract_urls(description)
        end

        def infringing_urls
          content.match(/url_box_\d+:(.+?)\n\n/m)
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
