require 'spec_helper'

describe InfringingUrlSerializer do
  it 'shares only the URL field' do
    url = build(:infringing_url)

    serializer = InfringingUrlSerializer.new(url)
    expect(serializer.as_json[:infringing_url].keys).to eq [:url]
  end
end
