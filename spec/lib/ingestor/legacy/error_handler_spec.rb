require 'spec_helper'
require 'ingestor'

describe Ingestor::Legacy::ErrorHandler do
  let(:directory) { 'tmp/example-import' }
  let(:headers) { %w|NoticeID OriginalFilePath| }

  before do
    FileUtils.mkdir_p directory

    File.open("#{directory}/tNotice.csv", 'w') do |fh|
      fh.puts headers.join(',')
      fh.puts "1000,sub/original.txt,sub/original.html"
    end
  end

  after do
    FileUtils.rm_rf 'tmp/example-import'
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
      @logger.should_receive(:error).with('  Files: sub/original.txt,sub/original.html')
      handler = described_class.new('tNotice.csv')

      handler.handle(csv_row, exception)
    end

    it "creates a relevant ImportError model instance" do
      NoticeImportError.should_receive(:create!).with(
        original_notice_id: 1000,
        file_list: 'sub/original.txt,sub/original.html',
        message: 'Boom!',
        stacktrace: 'first',
        import_set_name: 'tNotice.csv'
      )
      handler = described_class.new('tNotice.csv')

      handler.handle(csv_row, exception)
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
