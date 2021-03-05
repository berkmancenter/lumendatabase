require 'yt_importer/mapping/plain_new/base'

module YtImporter
  module Mapping
    module PlainNew
      class Defamation < Base
        NOTICE_TYPE_LABEL = 'Defamation'

        def notice_type
          ::Defamation
        end

        def jurisdiction
          get_single_line_field('country').split(',')
        end

        private

        def parsed_infringing_urls
          @notice_text.scan(/videourl:\s*(.+)\n/).flatten
        end

        def work_description
          get_naive_multiline_field(
            'identify_one:', 'where_one:'
          )
        end

        def sender
          behalf_client = get_single_line_field('behalf_client')
          signature = get_single_line_field('Signature')

          name = signature if signature.present?
          name = behalf_client if behalf_client.present?

          build_role('sender', name)
        end

        def principal
          behalf_client = get_single_line_field('behalf_client')
          legal_name = get_single_line_field('Fulllegalname')

          name = legal_name if legal_name.present?
          name = behalf_client if behalf_client.present?

          build_role('principal', name)
        end
      end
    end
  end
end
