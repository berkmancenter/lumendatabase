require 'spec_helper'
require 'blog_importer'

describe BlogImporter do

  it "converts HTML to markdown via Html2Md " do
    allow(BlogEntry).to receive(:create!).and_return(BlogEntry.new)
    blog_entry = attributes_for(:blog_entry, :with_abstract, :with_content)

    html2md = Html2Md.new('bupkis')
    expect(Html2Md).to receive(:new).twice.and_return(html2md)

    with_csv_file_for(blog_entry) do |csv_file|
      importer = described_class.new(csv_file.path)
      importer.import
    end
  end

  def with_csv_file_for(blog_entry)
    Tempfile.open('csv') do |csv_file|
      headers = blog_entry.keys.sort
      csv = CSV.generate do |csv|
        csv << headers
        csv << headers.map{ |header| blog_entry[header] }
      end
      csv_file.write(csv)
      csv_file.rewind

      yield (csv_file)
    end
  end
end
