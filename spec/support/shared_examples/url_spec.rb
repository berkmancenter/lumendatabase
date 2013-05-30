shared_examples 'an object with a url' do

  it { should validate_presence_of :url }
  it { should ensure_length_of(:url).is_at_most(1.kilobyte) }
  ['http://foo.com',
    '//bar.com',
    'https://example.com/asdfasdf',
    'http://foo@bar:example.com/',
    'http://foofarexample.com:3000/',
    'hTTps://example.com/asdfasdf?foobarbaz',
    'HTTP://example.com/asdfasdf#bleep',
    'https://example.com/asdfasfd?foo=bar#bleep',
    'ftp://example.com'
  ].each do |good_url|
    it { should allow_value(good_url).for(:url) }
  end

  ['', 'bee', 'brap.com', 1, nil].each do |bad_url|
    it { should_not allow_value(bad_url).for(:url) }
  end

end
