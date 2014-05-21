require 'ingestor/importer/base'

module Ingestor
  module Importer
    module Youtube
      class TrademarkD < Base

        handles_content(/^IssueType: trademarkcomplaintd/)

        def default_recipient
          'Youtube (Google, Inc.)'
        end

        def notice_type
          Trademark
        end

        def parse_mark_registration_number(file_path)
          contents = self.class.read_file(file_path)
          get_single_line_field(contents, 'registrationno')
        end

        def parse_works(file_path)
          contents = self.class.read_file(file_path)
          infringing_urls = parsed_infringing_urls(contents).map do |url|
            InfringingUrl.new(url: url)
          end
          [
            Work.new(
              description: work_description(contents),
              infringing_urls: infringing_urls
            )
          ]
        end

        private

        def parsed_infringing_urls(contents)
          contents.scan(/multi_video_urls:\s*(.+)\n/).flatten
        end

        def work_description(contents)
          get_naive_multiline_field(
            contents, 'trademark2_describe:', 'trademark2_agree:'
          )
        end

        def principal(content)
          get_naive_multiline_field(content, 'trademark2_owner:', 'trademark2_relation:')
        end

        def sender(content)
          [
            get_naive_multiline_field(content, 'fulllegalname:', 'trademark2_title:'),
            get_naive_multiline_field(content, 'trademark2_relation:', 'trademark2_email:'),
          ].reject { |val| val.blank? }.join(', ').strip
        end

      end
    end
  end
end
