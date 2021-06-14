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
          jurisdictions = get_single_line_field('Jurisdiction_one_other')

          return [] if jurisdictions.blank?

          jurisdictions.split(',')
        end

        def parsed_infringing_urls
          @notice_text.scan(/video_url:\s*(.+)\n/).flatten +
            @notice_text.scan(/channel_url:\s*(.+)\n/).flatten
        end

        def work_description
          description = get_naive_multiline_field(
            'AllegedlyInfringed:', 'AffirmationOne:'
          )

          infringement_type = get_single_line_field('InfringementType')
          description << "\n\n Infringement type: #{infringement_type}" if infringement_type

          description
        end

        def sender
          name = [
            get_single_line_field('Fulllegalname'),
            get_single_line_field('CompanyName')
          ].reject(&:blank?).uniq.join(', ').strip

          return nil if name.blank?

          build_role('sender', name)
        end

        def parse_mark_registration_number
          get_single_line_field('AppRegNumber')
        end

        def principal
          behalf_client = get_single_line_field('TrademarkOwnerName')

          return nil if behalf_client.blank?

          build_role('principal', behalf_client)
        end
      end
    end
  end
end
