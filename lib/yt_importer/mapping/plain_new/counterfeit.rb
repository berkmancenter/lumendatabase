require 'yt_importer/mapping/plain_new/trademark_d'

module YtImporter
  module Mapping
    module PlainNew
      class Counterfeit < TrademarkD
        NOTICE_TYPE_LABEL = 'Counterfeit'

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

        def principal
          name = get_single_line_field('TrademarkOwner')

          return nil unless name.present?

          build_role('principal', name)
        end
      end
    end
  end
end
