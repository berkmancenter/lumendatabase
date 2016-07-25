require 'rails_helper'

describe TopicManager, type: :model do
  context 'automatic validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
  end
  it { is_expected.to have_and_belong_to_many :topics }
end
