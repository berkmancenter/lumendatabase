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
      expect(json[:works].map { |w| w['description'] }).to eq(notice.works.map(&:description))
    end
  end

  %i|infringing_urls copyrighted_urls|.each do |url_relation|
    it "includes #{url_relation}" do
      with_a_serialized_notice do |notice, json|
        relation_json = json[:works].first[url_relation].map{|u| u['url']}
        expect(relation_json).to eq(
          notice.works.first.send(url_relation).map(&:url)
        )
        expect(relation_json.length).not_to eq 0
      end
    end
  end

end

def with_a_serialized_notice
  notice = build_notice
  serializer = described_class.new(notice, root: class_as_symbol)
  yield notice, serializer.as_json[class_as_symbol]
end

def build_notice
  build(class_as_symbol).tap do|notice|
    notice.stub(:recipient_name).and_return('recipient name')
    notice.stub(:sender_name).and_return('sender name')
    notice.stub(:tag_list).and_return(['foo', 'bar'])
    notice.stub(:jurisdiction_list).and_return(['US', 'CA'])
    notice.stub(:categories).and_return(
      build_list(:category, 2)
    )
    notice.stub(:works).and_return(
      build_list(:work, 3, :with_infringing_urls, :with_copyrighted_urls)
    )
    if described_class == NoticeSearchResultSerializer
      notice.stub(:_score).and_return(1)
      notice.stub(:score).and_return(1)
    end
  end
end

def class_as_symbol
  described_class.to_s.downcase.gsub(/serializer/,'').to_sym
end
