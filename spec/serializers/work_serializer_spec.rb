require 'spec_helper'

describe WorkSerializer do
  it 'has a fallback when there are no associated urls' do
    work = build(:work)
    expect(work.infringing_urls).to be_empty
    expect(work.copyrighted_urls).to be_empty

    serializer = WorkSerializer.new(work)

    [
      serializer.as_json[:work][:infringing_urls][0][:url],
      serializer.as_json[:work][:copyrighted_urls][0][:url]
    ].each do |val|
      expect(val).to eq 'No URL submitted'
    end

    expect(serializer.as_json[:work][:infringing_urls][0].keys).to eq [:url]
    expect(serializer.as_json[:work][:copyrighted_urls][0].keys).to eq [:url]

    expect(serializer.as_json[:work][:infringing_urls].length).to eq 1
    expect(serializer.as_json[:work][:copyrighted_urls].length).to eq 1
  end
end
