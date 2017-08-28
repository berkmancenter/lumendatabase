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

      def require_review_if_works_empty?
        false
      end

    end
  end
end
