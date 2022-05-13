require 'spec_helper'

describe InfringingUrl, type: :model do
  context 'automatic validations' do
    it { is_expected.to validate_presence_of(:url_original) }

    it 'validates format of URLs' do
      url = 'https://tilde.club:443/path/to/myfile.html?utf8=✓#AnchorGoesHere'
      assert InfringingUrl.new(url: url).valid?
    end

    it 'allows URLs without a protocol' do
      url = '//tilde.club:443/path/to/myfile.html?utf8=✓#AnchorGoesHere'
      x=InfringingUrl.new(url: url)
      x.valid?
      puts x.errors.messages
      assert InfringingUrl.new(url: url).valid?
    end

    it 'allows concatenated URLs' do
      url = 'https://amazon.com/book/here/http://amazon.com/another/book/'
      assert InfringingUrl.new(url: url).valid?
    end
  end

  context '#url and #url_original' do
    it_behaves_like 'an object with a url'
  end

  context 'performance' do
    it "runs method in less than specified time" do
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      InfringingUrl.get_approximate_count
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      expect(end_time - start_time).to be <= 1.0
    end
  end
end
