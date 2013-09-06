require 'zlib'
require 'ingestor'

module Ingestor
  class LegacyCsv
    def self.open(file_path)
      new(file_path)
    end

    def initialize(file_path)
      @file_path = file_path
    end

    def import
      CSV.foreach(@file_path, headers: true) do |csv_row|
        attributes = AttributeMapper.new(csv_row.to_hash).mapped
        updated_at = attributes.delete(:updated_at)
        dmca = Dmca.create!(attributes)
        dmca.update_attributes(updated_at: updated_at)
      end
    end
  end
end
