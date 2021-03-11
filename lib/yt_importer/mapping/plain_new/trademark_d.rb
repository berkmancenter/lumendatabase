require 'yt_importer/mapping/plain_new/base'

module YtImporter
  module Mapping
    module PlainNew
      class TrademarkD < Base
        NOTICE_TYPE_LABEL = 'Trademark'

        def notice_type
          ::Trademark
        end

        def jurisdiction
          get_single_line_field('Jurisdiction_one_other').split(',')
        end

        def parsed_infringing_urls
          @notice_text.scan(/video_url:\s*(.+)\n/).flatten
        end

        def work_description
          description = get_naive_multiline_field(
            'AllegedlyInfringed:', 'AffirmationOne:'
          )

          infringement_type = get_single_line_field('InfringementType')
          if infringement_type
            description << "\n\n Infringement type: #{infringement_type}"
          end

          description
        end

        def sender
          name = [
            get_single_line_field('Fulllegalname'),
            get_single_line_field('CompanyName')
          ].reject(&:blank?).uniq.join(', ').strip

          build_role('sender', name)
        end

        def parse_mark_registration_number
          get_single_line_field('AppRegNumber')
        end

        def principal
          behalf_client = get_single_line_field('TrademarkOwnerName')

          build_role('principal', behalf_client)
        end
      end
    end
  end
end
