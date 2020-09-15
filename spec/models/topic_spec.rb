require 'rails_helper'

describe Topic, type: :model do
  context 'automatic validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
  end

  it { is_expected.to have_many(:topic_assignments).dependent(:destroy) }
  it { is_expected.to have_many(:notices).through(:topic_assignments) }
  it { is_expected.to have_and_belong_to_many :relevant_questions }

  context '#description_html' do
    it 'converts #description from markdown' do
      topic = build(:topic, description: 'Some *sweet* markdown')

      html = topic.description_html

      expect(html).to eq "<p>Some <em>sweet</em> markdown</p>\n"
    end
  end

  context 'post update reindexing' do
    it 'updates updated_at for every notice associated with a topic' do
      notice = create(:dmca)

      previous_updated_at = notice.updated_at
      topic = notice.topics.first
      topic.name = 'transparent change'
      topic.save

      notice.reload
      second_updated_at = notice.updated_at
      expect(second_updated_at).to be > previous_updated_at

      topic.update(name: 'Updatey McUpdateface')
      notice.reload
      expect(notice.updated_at).to be > second_updated_at
    end
  end

  it_behaves_like 'an object with hierarchical relationships'
end
