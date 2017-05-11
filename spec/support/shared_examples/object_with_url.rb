shared_examples 'an object with a url' do

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
    it { is_expected.to allow_value(good_url).for(:url) }
  end

  ['', 'bee', 'brap.com', 1, nil].each do |bad_url|
    it { is_expected.not_to allow_value(bad_url).for(:url) }
  end

end
