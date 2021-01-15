require 'yt_importer/mapping/plain/base'

module YtImporter
  module Mapping
    module Plain
      class TrademarkD < Base
        def notice_type
          Trademark
        end
      end
    end
  end
end
