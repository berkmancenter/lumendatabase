module Ingestor
  module Importer
    class GoogleSecondary
    include Ingestor::Importer::FileUploadHandler

      PARSERS = [
         DmcaParser,
         OtherParser
      ]

      attr_reader :file_paths

      def self.handles?(file_paths)
        file_paths && file_paths.split(',').any? do |file|
          File.open(file) { |f| f.grep(/^IssueType:/) }.present?
        end
      end

      def initialize(file_paths)
        @file_paths = (file_paths || '').split(',')
      end

      def works
        works = []
        original_file_paths.map do |original_file|
          contents = File.read(original_file)

          parser_class = PARSERS.find do |parser_class|
            parser_class.handles?(contents)
          end || DmcaParser

          parser = parser_class.new(contents)

          works << Work.new(
            description: parser.description,
            infringing_urls_attributes: url_mapper(parser.infringing_urls),
            copyrighted_urls_attributes: url_mapper(parser.copyrighted_urls)
          )
        end

        works
      end

      private

      def url_mapper(urls)
        urls.map { |url| { url: url} }
      end

      def original?(file_path)
        File.open(file_path) { |f| f.grep(/^IssueType:/) }.present?
      end

    end
  end
end
