module Ingestor
  module ImportDispatcher
    def self.for(original_file_paths, supporting_file_paths)
      file_paths = [
        original_file_paths,
        supporting_file_paths
      ].compact.join(',')

      importer_class = @registry.detect { |klass| klass.handles?(file_paths) }
      importer_class.new(original_file_paths, supporting_file_paths)
    end

    def self.register(klass)
      @registry ||= []
      @registry << klass
    end
  end
end
