require 'ingestor/importer/base'
require 'ingestor/importer/google_secondary/dmca_parser'
require 'ingestor/importer/google_secondary/other_parser'

module Ingestor
  module Importer
    class GoogleSecondary < Base

      PARSERS = [
         DmcaParser,
         OtherParser
      ]

      handles_content(/^IssueType:/)

      def parse_works(file_path)
        contents = File.read(file_path)

        parser_class = sub_parser_for(contents) || DmcaParser
        parser = parser_class.new(contents)

        Work.new(
          description: parser.description,
          infringing_urls_attributes: url_mapper(parser.infringing_urls),
          copyrighted_urls_attributes: url_mapper(parser.copyrighted_urls)
        )
      end

      def original?(file_path)
        File.open(file_path) { |f| f.grep(/^IssueType:/) }.present?
      end

      private

      def sub_parser_for(contents)
        PARSERS.detect do |parser_class|
          parser_class.handles?(contents)
        end
      end

      def url_mapper(urls)
        urls.map { |url| { url: url} }
      end

    end
  end
end
