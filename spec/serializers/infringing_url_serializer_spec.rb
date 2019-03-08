require 'spec_helper'

describe CopyrightedUrlSerializer do
  it 'shares only the URL field' do
    url = build(:copyrighted_url)

    serializer = CopyrightedUrlSerializer.new(url)
    expect(serializer.as_json[:copyrighted_url].keys).to eq [:url]
  end
end
