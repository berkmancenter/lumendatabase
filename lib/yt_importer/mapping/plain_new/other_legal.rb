require 'yt_importer/mapping/plain_new/trademark_d'

module YtImporter
  module Mapping
    module PlainNew
      class OtherLegal < TrademarkD
        NOTICE_TYPE_LABEL = 'Other Legal'

        def notice_type
          ::Other
        end

        def regulation_list
          get_single_line_field('cite_law').split(',')
        end

        def jurisdiction
          get_single_line_field('Country').split(',')
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

          build_role('sender', name)
        end

        def principal
          behalf_client = get_single_line_field('client')
          legal_name = get_single_line_field('Fulllegalname')

          name = legal_name if legal_name.present?
          name = behalf_client if behalf_client.present?

          build_role('principal', name)
        end
      end
    end
  end
end
