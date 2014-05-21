require 'ingestor/importer/base'
require 'ingestor/importer/youtube/trademark_d'

module Ingestor
  module Importer
    module Youtube
      class OtherLegal < TrademarkD

        handles_content(/^IssueType: otherlegal/)

        def notice_type
          Other
        end

        private

        def parsed_infringing_urls(contents)
          get_naive_multiline_field(
            contents, 'otherurls:', 'otheruser:'
          ).split(/\s/).reject { |url| url.blank? }
        end

        def work_description(contents)
          get_naive_multiline_field(
            contents, 'violating_law:', 'truecomplete:'
          )
        end

        def sender(content)
          get_naive_multiline_field(
            content, 'signature:', 'youtubelegalsupport_subject:'
          )
        end

        def principal(content)
          get_naive_multiline_field(content, 'fulllegalname:', 'yourusername:')
        end
      end
    end
  end
end
