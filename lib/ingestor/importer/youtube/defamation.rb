require 'ingestor/importer/base'

module Ingestor
  module Importer
    module Youtube
      class Defamation < Base

        handles_content(/^defamatoryvids:/)

        def default_recipient
          'Youtube (Google, Inc.)'
        end

        def notice_type
          ::Defamation
        end

        def parse_works(file_path)
          @contents = self.class.read_file(file_path)
          infringing_urls = defamatoryvids.map do |url|
            InfringingUrl.new(url: url)
          end

          [
            Work.new(
              description: work_description,
              infringing_urls: infringing_urls
            )
          ]
        end

        private

        def principal(content)
          [
            get_naive_multiline_field(content, 'fulllegalname:', 'yourusername:'),
            get_naive_multiline_field(content, 'yourusername:', 'defamatoryvids:'),
          ].join(' ').strip
        end

        def sender(content)
          get_naive_multiline_field(
            content, 'signature:', 'youtubelegalsupport_subject:'
          )
        end

        def work_description
          get_naive_multiline_field(
            @contents, '--Begin forwarded message--', 'country:'
          )
        end

        def defamatoryvids
          get_naive_multiline_field(
            @contents, 'defamatoryvids:', 'defamatoryusernames:'
          ).split(/\s/)
        end
      end
    end
  end
end
