require 'ingestor/importer/base'

module Ingestor
  module Importer
    class Google < Base

      handles_content(/^field_form_version:/)

      def parse_works(file_path)
        contents = self.class.read_file(file_path)
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

      def default_submitter
        'Google, Inc.'
      end

      def default_recipient
        'Google, Inc.'
      end

      private

      def sender(content)
        [
          get_field(content, 'submitter_first_name'),
          get_field(content, 'submitter_last_name')
        ].uniq.compact.join(' ').strip
      end

      def principal(content)
        get_field(content, 'copyright_owner')
      end

      def get_field(content, field_name)
        if content.match(/field_#{field_name}:(.+?)field_/m)
          $1.strip
        end
      end

    end
  end
end
