require 'ingestor/importer/base'
require 'ingestor/importer/youtube/trademark_d'

module Ingestor
  module Importer
    module Youtube
      class Counterfeit < TrademarkD

        handles_content(/^IssueType: counterfeit/)

        private

        def parsed_infringing_urls(contents)
          contents.scan(/videourl:\s*(.+)\n/).flatten
        end

        def work_description(contents)
          get_naive_multiline_field(
            contents, 'trademark_clarifications:', 'counterfeit_goodfaith_check:'
          )
        end

        def sender(content)
          [
            get_naive_multiline_field(content, 'fulllegalname:', 'trademark2_title:'),
            get_naive_multiline_field(content, 'trademark2_title:', 'companyname:'),
            get_naive_multiline_field(content, 'companyname:', 'country:'),
          ].reject { |val| val.blank? }.join(', ').strip
        end

        def principal(content)
          get_naive_multiline_field(content, 'trademarkowner:', 'counterfeit_address:')
        end
      end
    end
  end
end
