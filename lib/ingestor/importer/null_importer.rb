module Ingestor
  module Importer
    class NullImporter
      def self.handles?(*)
        true
      end

      attr_reader :file_paths,
        :file_upload,
        :file_uploads,
        :notice_type,
        :original_documents,
        :original_file_paths,
        :parse_works,
        :supporting_documents,
        :supporting_file_paths,
        :works

      def initialize(*)
        @file_paths = @file_uploads = @original_documents = 
          @supporting_documents = @works = []
        @notice_type = Dmca
      end

      def original?
      end

    end
  end
end
