require 'ingestor/importer/base'

module Ingestor
  module Importer
    class UnknownImporter < Base

      def self.handles?(*)
        true
      end

      def parse_works(*)
        []
      end

    end
  end
end
