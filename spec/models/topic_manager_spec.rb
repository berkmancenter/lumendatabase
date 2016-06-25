require 'rails_helper'

describe TopicManager, type: :model do
  context 'automatic validations' do
    it { should validate_presence_of :name }
    it { should validate_length_of(:name).is_at_most(255) }
  end
  it { should have_and_belong_to_many :topics }
end
