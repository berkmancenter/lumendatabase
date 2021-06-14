require 'yt_importer/mapping/plain_new/trademark_d'

module YtImporter
  module Mapping
    module PlainNew
      class Counterfeit < TrademarkD
        NOTICE_TYPE_LABEL = 'Counterfeit'

        def notice_type
          ::Counterfeit
        end

        def jurisdiction
          get_single_line_field('Country').split(',')
        end

        private

        def parsed_infringing_urls
          @notice_text.scan(/videourl:\s*(.+)\n/).flatten
        end

        def work_description
          get_naive_multiline_field(
            'Clarify:', 'AffirmationOne:'
          )
        end

        def sender
          full_legal_name = get_single_line_field('Fulllegalname')
          company_name = get_single_line_field('CompanyName')

          name = full_legal_name if full_legal_name.present?
          name = company_name if company_name.present?

          return nil if name.blank?

          build_role('sender', name)
        end

        def principal
          name = get_single_line_field('TrademarkOwner')

          return nil if name.blank?

          build_role('principal', name)
        end
      end
    end
  end
end
