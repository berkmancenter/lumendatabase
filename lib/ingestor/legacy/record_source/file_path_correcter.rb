module Ingestor
  class Legacy
    class RecordSource
      class FilePathCorrector

        def self.correct_paths(paths)
          file_paths = paths.split(',')
          actual_files = []
          file_paths.each do |file_path|
            potential_paths(file_path).each do |potential_path|
              if File.exists?(potential_path)
                actual_files << potential_path
                break
              end
            end
          end
          actual_files.join(',')
        end

        private

        def self.potential_paths(file_path)
          [
            file_path.sub(/\.html$/, '.txt'),
            file_path,
            file_path.sub(%r{files_by_time/\d{4}/(\d{2}/){3}}, '')
          ].uniq
        end

      end
    end
  end
end
