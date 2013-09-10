module Ingestor
  module Importer
    module FileUploadHandler

      def original_documents
        original_file_paths.map do |file_path|
          FileUpload.new(
            kind: 'original',
            file: File.open(file_path)
          )
        end
      end

      def supporting_documents
        supporting_file_paths.map do |file_path|
          FileUpload.new(
            kind: 'supporting',
            file: File.open(file_path)
          )
        end
      end

      def file_uploads
        original_documents + supporting_documents
      end

      def original_file_paths
        file_paths.select { |file_path| original?(file_path) }
      end

      def supporting_file_paths
        file_paths.reject { |file_path| original?(file_path) }
      end
    end

  end
end
