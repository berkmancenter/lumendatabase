require 'rails_helper'

shared_examples 'a serialized notice with base metadata' do |factory_name|

  factory_name ||= :dmca

  it 'includes base notice metadata' do
    with_a_serialized_notice(factory_name) do |notice, json|
      %i(title type body date_sent date_received sender_name recipient_name action_taken language).each do |att|
        expect(json[att]).to eq notice.send(att)
      end
    end
  end

  it 'includes topics' do
    with_a_serialized_notice(factory_name) do |notice, json|
      expect(json[:topics]).to eq notice.topics.map(&:name)
    end
  end

  it 'includes tags' do
    with_a_serialized_notice(factory_name) do |notice, json|
      expect(json[:tags]).to match_array notice.tag_list
    end
  end

  it 'includes jurisdictions' do
    with_a_serialized_notice(factory_name) do |notice, json|
      expect(json[:jurisdictions]).to match_array notice.jurisdiction_list
    end
  end

end

def with_a_serialized_notice(factory_name = :dmca)
  notice = build_notice(factory_name)
  serializer = described_class.new(notice, root: factory_name)
  yield notice, serializer.as_json[factory_name]
end

def build_notice(factory_name = :dmca)
  build(factory_name).tap do|notice|
    allow(notice).to receive(:recipient_name).and_return('recipient name')
    allow(notice).to receive(:sender_name).and_return('sender name')
    allow(notice).to receive(:tag_list).and_return(['foo', 'bar'])
    allow(notice).to receive(:jurisdiction_list).and_return(['US', 'CA'])
    allow(notice).to receive(:language).and_return('en')
    allow(notice).to receive(:topics).and_return(
      build_list(:topic, 2)
    )
    allow(notice).to receive(:works).and_return(
      build_list(:work, 3, :with_infringing_urls, :with_copyrighted_urls)
    )
  end
end
