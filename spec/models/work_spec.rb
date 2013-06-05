require 'spec_helper'

describe Work do
  it { should have_and_belong_to_many :notices }
  it { should have_and_belong_to_many :infringing_urls }

  context 'schema_validations' do
    it { should ensure_length_of(:kind).is_at_most(255) }
  end

  context '#infringing_urls' do
    it "does not create duplicate infringing_urls" do
      existing_infringing_url = create(
        :infringing_url, url: 'http://www.example.com/infringe'
      )
      duplicate_infringing_url = build(
        :infringing_url, url: 'http://www.example.com/infringe'
      )
      new_infringing_url = build(
        :infringing_url, url: 'http://example.com/new'
      )

      work = build(
        :work,
        infringing_urls: [duplicate_infringing_url, new_infringing_url]
      )
      work.save

      work.reload

      expect(work.infringing_urls).to include existing_infringing_url
      expect(InfringingUrl.count).to eq 2
    end
  end

  context '#url' do
    it_behaves_like 'an object with a url'
  end

  context '#kind' do
    it "auto classifies before saving if kind is not set" do
      DeterminesWorkKind.any_instance.should_receive(:kind).and_return('foo')
      work = build(:work, url: 'http://www.example.com/foo.mp3')

      work.save
      expect(work.kind).to eq 'foo'
    end

    it "does not auto classify if kind is set" do
      DeterminesWorkKind.any_instance.should_not_receive(:kind)
      work = build(:work, url: 'http://www.example.com/foo.mp3', kind: 'foo')

      work.save
    end
  end
end
