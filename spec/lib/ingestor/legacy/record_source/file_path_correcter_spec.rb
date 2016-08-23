require 'spec_helper'
require 'ingestor'

describe Ingestor::Legacy::RecordSource::FilePathCorrector do
  include ImporterFileHelpers

  before do
    FileUtils.mkdir_p test_directory
  end

  after do
    FileUtils.rm_rf test_directory
  end

  it "calculates paths properly" do
    Dir.chdir(test_directory) do
      allow(File).to receive(:exists?).and_return(:true)
      corrected_paths = described_class.correct_paths(
        'foo.txt,bar.html,files_by_time/4444/22/22/22/baz.html,sub/bat.html'
      )

      expect(corrected_paths).to eq(
      'foo.txt,bar.txt,files_by_time/4444/22/22/22/baz.txt,sub/bat.txt'
      )
    end
  end

  it "tests for file existence correctly" do
    Dir.chdir(test_directory) do
      touch_file('bar.txt')

      corrected_paths = described_class.correct_paths(
        'foo.txt,bar.html,files_by_time/4444/22/22/22/baz.html,sub/bat.html'
      )

      expect(corrected_paths).to eq 'bar.txt'
    end
  end

  def test_directory
    'tmp/correcter_test'
  end

end
