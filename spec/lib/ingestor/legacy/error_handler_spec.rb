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
    end

    it "outputs the failure via its logger" do
      expect(Rails.logger).to receive(:error).with('legacy import error original_notice_id: 1000, name: tNotice.csv, message: "(RuntimeError) Boom!: first"')
      handler = described_class.new('tNotice.csv')

      handler.handle(csv_row, exception)
    end

    it "creates a relevant ImportError model instance" do
      expect(NoticeImportError).to receive(:create!).with(
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
        allow(ex).to receive(:backtrace).and_return(%w( first second third ))
      end
    end
  end
end
