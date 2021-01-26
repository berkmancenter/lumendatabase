require 'yt_importer/mapping/plain/base'

module YtImporter
  module Mapping
    module PlainNew
      class Defamation < Base
        def notice_type
          ::Defamation
        end
      end
    end
  end
end
