module Ingestor
  module WorksImporter
    class Dispatcher
      def self.import(file_path)
        @file_path = file_path
        original_file = find_original_file
        if original_file.present?
          importer_class = @registry.find{ |klass| klass.handles?(original_file) }
          importer_class.works(original_file) || []
        else
          []
        end
      end

      def self.register(klass)
        @registry ||= []
        @registry << klass
      end

      private

      def self.find_original_file
        @file_path && @file_path.split(',').find{ |file| file.match(/.+.txt\z/) }
      end
    end
  end
end
