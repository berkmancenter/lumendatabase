module Ingestor
  module WorksImporter
    class NullImporter
      def self.handles?(*args)
        true
      end

      def self.works(*arg)
        []
      end
    end
  end
end
