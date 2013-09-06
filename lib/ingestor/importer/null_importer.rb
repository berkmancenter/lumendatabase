module Ingestor
  module Importer
    class NullImporter
      def self.handles?(*)
        true
      end

      attr_reader :works, :file_uploads

      def initialize(*)
        @works = []
        @file_uploads = []
      end
    end
  end
end
