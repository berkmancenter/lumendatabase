module Ingestor
  module Importer
    class Google
    include Ingestor::Importer::FileUploadHandler

      attr_reader :file_paths

      def self.handles?(file_paths)
        file_paths && file_paths.split(',').any? do |file|
          File.open(file) { |f| f.grep(/^field_form_version:/) }.present?
        end
      end

      def initialize(file_paths)
        @file_paths = (file_paths || '').split(',')
      end

      def works
        original_file_paths.map { |file_path| parse_works(file_path) }.flatten
      end

      private

      def parse_works(file_path)
        contents = File.read(file_path)
        field_groups = FindFieldGroups.new(contents).find

        field_groups.map do |field_group|
          parser = FieldGroupParser.new(field_group)

          copyrighted_urls = parser.copyrighted_urls.map do |url|
            CopyrightedUrl.new(url: url)
          end

          infringing_urls = parser.infringing_urls.map do |url|
            InfringingUrl.new(url: url)
          end

          Work.new(
            description: parser.description,
            copyrighted_urls: copyrighted_urls,
            infringing_urls: infringing_urls
          )
        end
      end

      def original?(file_path)
        File.extname(file_path) == '.txt'
      end

    end
  end
end
