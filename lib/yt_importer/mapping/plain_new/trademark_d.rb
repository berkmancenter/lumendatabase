require 'yt_importer/mapping/plain_new/base'

module YtImporter
  module Mapping
    module PlainNew
      class TrademarkD < Base
        NOTICE_TYPE_LABEL = 'Trademark'

        def notice_type
          ::Trademark
        end

        def parsed_infringing_urls
          @notice_text.scan(/video_url:\s*(.+)\n/).flatten
        end

        def work_description
          get_naive_multiline_field(
            'AllegedlyInfringed:', 'AffirmationOne:'
          )
        end

        def sender
          name = [
            get_single_line_field('Fulllegalname'),
            get_single_line_field('CompanyName')
          ].reject { |val| val.blank? }.join(', ').strip

          build_role('sender', name)
        end

        def principal
          behalf_client = get_single_line_field('TrademarkOwnerName')
          legal_name = get_single_line_field('Fulllegalname')

          build_role('principal', behalf_client || legal_name)
        end
      end
    end
  end
end
