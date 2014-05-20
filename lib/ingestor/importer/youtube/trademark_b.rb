require 'ingestor/importer/base'
require 'ingestor/importer/youtube/trademark_d'

module Ingestor
  module Importer
    module Youtube
      class TrademarkB < TrademarkD

        handles_content(/^IssueType: trademarkcomplaintb/)

        private

        def parsed_infringing_urls(contents)
          Array(
            get_naive_multiline_field(
              contents, 'trademark2_username:', 'trademark2_usernameremoval:'
            )
          )
        end
      end
    end
  end
end
