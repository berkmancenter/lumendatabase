require 'yt_importer/mapping/plain_new/trademark_d'

module YtImporter
  module Mapping
    module PlainNew
      class OtherLegal < TrademarkD
        NOTICE_TYPE_LABEL = 'Other Legal'

        def notice_type
          ::Other
        end

        private

        def parsed_infringing_urls
          @notice_text.scan(/video_url:\s*(.+)\n/).flatten
        end

        def work_description
          puts get_naive_multiline_field(
            'content:', 'affirmation_one:'
          )
          get_naive_multiline_field(
            'content:', 'affirmation_one:'
          )
        end

        def sender
          name = get_single_line_field('Signature')

          return nil unless name.present?

          build_role('sender', name)
        end

        def principal
          behalf_client = get_single_line_field('client')
          legal_name = get_single_line_field('Fulllegalname')

          build_role('principal', behalf_client || legal_name)
        end
      end
    end
  end
end
