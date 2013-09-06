module Ingestor
  module ImportDispatcher
    def self.for(file_paths)
      importer_class = @registry.find { |klass| klass.handles?(file_paths) }
      importer_class.new(file_paths)
    end

    def self.register(klass)
      @registry ||= []
      @registry << klass
    end
  end
end
