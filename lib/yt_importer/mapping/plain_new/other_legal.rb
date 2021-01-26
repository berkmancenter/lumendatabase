require 'yt_importer/mapping/plain/trademark_d'

module YtImporter
  module Mapping
    module PlainNew
      class OtherLegal < TrademarkD
        def notice_type
          Other
        end
      end
    end
  end
end
