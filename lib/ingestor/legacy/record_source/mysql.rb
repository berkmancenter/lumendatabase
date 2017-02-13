require 'mysql2'

module Ingestor
  class Legacy
    class RecordSource
      class Mysql
        attr_reader :base_directory, :name

        def initialize(where, name, base_directory = 'imports')
          @where = where
          @name = name
          @base_directory = base_directory
          @connection = Mysql2::Client.new(
            host: ENV['MYSQL_HOST'],
            username: ENV['MYSQL_USERNAME'],
            password: ENV['MYSQL_PASSWORD'],
            port: ENV['MYSQL_PORT'].to_i,
            database: ENV['MYSQL_DATABASE'],
            reconnect: true,
            read_timeout: 28800,
            connect_timeout: 28800
          )
          @results = @connection.query(query, stream: true, cache_rows: false)
        end

        def each
          @results.each do |row|
            correct_paths(row)
            yield row
          end
        end

        def correct_paths(row)
          ['OriginalFilePath', 'SupportingFilePath'].each do |file_type|
            if paths = row.delete(file_type)
              row[file_type] = FilePathCorrector.correct_paths(paths)
            end
          end
        end

        def headers
          ( @results.first && @results.first.keys ) || []
        end

        private

        attr_accessor :where

        def query
return <<EOSQL
SELECT tNotice.*, unredacted.Body as BodyOriginal,
       group_concat(originals.Location)  AS OriginalFilePath,
       group_concat(supporting.Location) AS SupportingFilePath,
       tCat.CatName as CategoryName, rSubmit.sID as SubmissionID
  FROM tNotice
LEFT JOIN tNotImage originals
       ON originals.NoticeID   = tNotice.NoticeID
      AND originals.ReadLevel != 0
LEFT JOIN tNoticePriv as unredacted
      on  unredacted.NoticeID    = tNotice.NoticeID
LEFT JOIN tNotImage supporting
       ON supporting.NoticeID   = tNotice.NoticeID
      AND supporting.ReadLevel  = 0
LEFT JOIN tCat
       ON tCat.CatId = tNotice.CatId
LEFT JOIN rSubmit
       ON rSubmit.NoticeID = tNotice.NoticeID
WHERE #{where}
GROUP BY tNotice.NoticeID
ORDER BY tNotice.NoticeID ASC
EOSQL
        end

      end
    end
  end
end
