require 'ingestor/importer/base'

module Ingestor
  module Importer
    class Google < Base

      handles_content(/^field_form_version:/)

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

    end
  end
end
