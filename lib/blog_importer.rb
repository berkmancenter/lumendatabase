require 'html2md'

class BlogImporter

  def initialize(csv_file)
    @csv_file = csv_file
  end

  def import
    CSV.foreach(csv_file, headers: true) { |csv_row| import_row(csv_row) }
  end

  private

  def import_row(row)
    BlogEntry.create!(map_attributes(row.to_hash))
  end

  attr_reader :csv_file

  def map_attributes(row)
    row['original_news_id'] = row.delete('NewsID')
    row['topics'] = Topic.where(name: row.delete('CategoryName'))
    if row['author'].blank?
      row['author'] = 'Unknown'
    end
    %w/abstract content/.each do |column|
      if html_content = row.delete(column)
        row[column] = html2md(html_content, row['original_news_id'])
      end
    end
    row
  end

  def html2md(string, original_news_id)
    converted = ''
    begin
      converter = Html2Md.new(string)
      converted = converter.parse
    rescue Exception => e
      $stderr.puts "BlogImporter: original_news_id: #{original_news_id} could not convert automatically to markdown."
      converted = string
    end
  end

end
