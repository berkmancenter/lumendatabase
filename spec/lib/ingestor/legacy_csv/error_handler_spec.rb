require 'spec_helper'
require 'ingestor'

describe Ingestor::LegacyCsv::ErrorHandler do
  let(:directory) { 'tmp/example-import' }

  before do
    FileUtils.mkdir_p directory

    File.open("#{directory}/tNotice.csv", 'w') do |fh|
      fh.puts "NoticeID,OriginalFilePath"
      fh.puts "1000,sub/original.txt,sub/original.html"
    end
  end

  after do
    FileUtils.rm_rf 'tmp/example-import'
    FileUtils.rm_rf 'tmp/example-import-failures'
  end

  context "error report file name" do
    it "is relative to the import file name" do
      file_name = 'foobar.csv'
      handler = described_class.new(directory, file_name)

      expect(File.exists?("#{directory}-failures/foobar.csv")).to be
    end
  end

  context ".copy_headers" do
    it "copies the headers with another column" do
      handler = described_class.new(directory, 'tNotice.csv')

      handler.copy_headers("#{directory}/tNotice.csv")

      handler.close
      contents = File.read("#{directory}-failures/tNotice.csv").chomp
      expect(contents).to eq "NoticeID,OriginalFilePath,FailureMessage"
    end
  end

  context "#handle" do
    before do
      FileUtils.mkdir_p "#{directory}/sub"
      File.open("#{directory}/sub/original.txt", 'w') { }
      File.open("#{directory}/sub/original.html", 'w') { }

      @logger = double("Logger")
      @logger.stub(:error)
      Logger.stub(:new).and_return(@logger)
    end

    it "outputs the failure via its logger" do
      @logger.should_receive(:error).with('Error importing Notice 1000 from tNotice.csv')
      @logger.should_receive(:error).with('  Error: (RuntimeError) Boom!: first')
      @logger.should_receive(:error).with('  Files: sub/original.txt, sub/original.html')
      handler = described_class.new(directory, 'tNotice.csv')

      Dir.chdir(directory) { handler.handle(csv_row, exception) }
    end

    it "records the CSV row and failure" do
      handler = described_class.new(directory, 'tNotice.csv')

      Dir.chdir(directory) { handler.handle(csv_row, exception) }

      handler.close
      contents = File.read("#{directory}-failures/tNotice.csv").chomp
      expect(contents).to eq(
        '1000,"sub/original.txt,sub/original.html",(RuntimeError) Boom!: first'
      )
    end

    it "copies any original files" do
      handler = described_class.new(directory, 'tNotice.csv')

      Dir.chdir(directory) { handler.handle(csv_row, exception) }

      expect(File.exists?("#{directory}-failures/sub/original.txt")).to be
      expect(File.exists?("#{directory}-failures/sub/original.html")).to be
    end

    private

    def csv_row
      CSV::Row.new(
        ['NoticeID', 'OriginalFilePath'],
        ['1000', 'sub/original.txt,sub/original.html']
      )
    end

    def exception
      RuntimeError.new("Boom!").tap do |ex|
        ex.stub(:backtrace).and_return(%w( first second third ))
      end
    end
  end
end
