require 'rails_helper'

describe Topic, type: :model do
  context 'automatic validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
  end

  it { is_expected.to have_many(:topic_assignments).dependent(:destroy) }
  it { is_expected.to have_many(:notices).through(:topic_assignments) }
  it { is_expected.to have_many(:blog_entry_topic_assignments).dependent(:destroy) }
  it { is_expected.to have_many(:blog_entries).through(:blog_entry_topic_assignments) }
  it { is_expected.to have_and_belong_to_many :relevant_questions }

  context "#description_html" do
    it "converts #description from markdown" do
      topic = build(:topic, description: "Some *sweet* markdown")

      html = topic.description_html

      expect(html).to eq "<p>Some <em>sweet</em> markdown</p>\n"
    end
  end

  context 'post update reindexing' do
    it "uses the TopicIndexQueuer to schedule notices for indexing" do
      topic = create(:topic)
      expect(TopicIndexQueuer).to receive(:for).with(topic.id)

      topic.save
    end
  end

  it_behaves_like 'an object with hierarchical relationships'
end
