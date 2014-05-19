require 'spec_helper'

describe Topic do
  context 'automatic validations' do
    it { should validate_presence_of :name }
    it { should ensure_length_of(:name).is_at_most(255) }
  end

  it { should have_many(:topic_assignments).dependent(:destroy) }
  it { should have_many(:notices).through(:topic_assignments) }
  it { should have_many(:blog_entry_topic_assignments).dependent(:destroy) }
  it { should have_many(:blog_entries).through(:blog_entry_topic_assignments) }
  it { should have_and_belong_to_many :relevant_questions }

  context "#description_html" do
    it "converts #description from markdown" do
      topic = build(:topic, description: "Some *sweet* markdown")

      html = topic.description_html

      expect(html).to eq "<p>Some <em>sweet</em> markdown</p>\n"
    end
  end

  it_behaves_like 'an object with hierarchical relationships'
end
