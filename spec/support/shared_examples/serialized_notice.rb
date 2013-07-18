shared_examples 'a serialized notice' do

  it 'includes base notice metadata' do
    with_a_serialized_notice do |notice, json|
      %i(title body date_sent date_received sender_name recipient_name).each do |att|
        expect(json[att]).to eq notice.send(att)
      end
    end
  end

  it 'includes categories' do
    with_a_serialized_notice do |notice, json|
      expect(json[:categories]).to eq notice.categories.map(&:name)
    end
  end

  it 'includes tags' do
    with_a_serialized_notice do |notice, json|
      expect(json[:tags]).to match_array notice.tag_list
    end
  end

  it 'includes jurisdictions' do
    with_a_serialized_notice do |notice, json|
      expect(json[:jurisdictions]).to match_array notice.jurisdiction_list
    end
  end

  it 'includes works' do
    with_a_serialized_notice do |notice, json|
      expect(json[:works].map { |w| w['url'] }).to eq(notice.works.map(&:url))
    end
  end

  it 'includes infringing_urls' do
    with_a_serialized_notice do |notice, json|
      infringing_urls_json = json[:works].first[:infringing_urls].map{|u| u['url']}
      expect(infringing_urls_json).to eq(
        notice.works.first.infringing_urls.map(&:url)
      )
      expect(infringing_urls_json.length).not_to eq 0
    end
  end

end

def with_a_serialized_notice
  notice = build_notice
  serializer = described_class.new(notice, root: :notice)
  yield notice, serializer.as_json[:notice]
end

def build_notice
  build(:notice).tap do|notice|
    notice.stub(:recipient_name).and_return('recipient name')
    notice.stub(:sender_name).and_return('sender name')
    notice.stub(:tag_list).and_return(['foo', 'bar'])
    notice.stub(:jurisdiction_list).and_return(['US', 'CA'])
    notice.stub(:categories).and_return(
      build_list(:category, 2)
    )
    notice.stub(:works).and_return(
      build_list(:work, 3, :with_infringing_urls)
    )
    if described_class == NoticeSearchResultSerializer
      notice.stub(:_score).and_return(1)
      notice.stub(:score).and_return(1)
    end
  end
end
