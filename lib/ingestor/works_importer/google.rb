require 'ingestor/works_importer/google/find_field_groups'
require 'ingestor/works_importer/google/field_group_parser'

module Ingestor
  module WorksImporter
    class Google

      def self.handles?(file_path)
        File.open(file_path){ |f| f.grep(/^field_form_version:/) }.present?
      end

      def initialize(file_path)
        @file_path = file_path
        @works = {}
      end

      def self.works(file_path)
        importer = self.new(file_path)
        works_instances = []
        importer.parse_works.each do |field_group_index, data|
          works_instances << Work.new(
            description: data[:description],
            infringing_urls_attributes: data[:infringing_urls].collect{|url| {url: url}},
            copyrighted_urls_attributes: data[:copyrighted_urls].collect{|url| {url: url}}
          )
        end
        works_instances
      end

      def parse_works
        contents = File.read(@file_path)

        field_groups = FindFieldGroups.new(contents).find

        field_groups.each do |field_group, field_group_content|
          parser = FieldGroupParser.new(field_group, field_group_content)

          @works[field_group] = {}
          @works[field_group][:description] = parser.description
          @works[field_group][:copyrighted_urls] = parser.copyrighted_urls
          @works[field_group][:infringing_urls] = parser.infringing_urls
        end
        @works
      end
    end
  end
end
