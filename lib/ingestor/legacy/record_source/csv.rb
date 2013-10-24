require 'csv'

module Ingestor
  class Legacy
    class RecordSource
      class CSV
        attr_reader :base_directory, :name

        def initialize(file_path)
          @file_path = file_path
          @base_directory, @name = File.split(file_path)
        end

        def each
          ::CSV.foreach(name, headers: true) do |row|
            yield row
          end
        end

        def headers
          File.open(file_path, &:readline).chomp.split(',')
        end

        private

        attr_accessor :file_path

      end
    end
  end
end
