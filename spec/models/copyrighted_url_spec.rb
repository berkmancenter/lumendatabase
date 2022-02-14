require 'rails_helper'

RSpec.describe CopyrightedUrl, type: :model do
  context 'automatic validations' do
    it { is_expected.to validate_presence_of(:url_original) }

    it 'validates format of URLs' do
      url = 'https://tilde.club:443/path/to/myfile.html?utf8=✓#AnchorGoesHere'
      assert !!(url =~ URI::regexp)
      assert CopyrightedUrl.new(url: url).valid?
    end

    it 'allows URLs without a protocol' do
      url = '//tilde.club:443/path/to/myfile.html?utf8=✓#AnchorGoesHere'
      assert !!("http:#{url}" =~ URI::regexp)
      assert CopyrightedUrl.new(url: url).valid?
    end

    it 'allows concatenated URLs' do
      url = 'https://amazon.com/book/here/http://amazon.com/another/book/'
      assert CopyrightedUrl.new(url: url).valid?
    end
  end

  context "#url" do
    it_behaves_like 'an object with a url'
  end

  context "#url_original" do
    it_behaves_like 'an object with a url'
  end
end
