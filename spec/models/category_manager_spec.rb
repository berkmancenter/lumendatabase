require 'spec_helper'

describe CategoryManager do
  context 'schema_validations' do
    it { should validate_presence_of :name }
    it { should ensure_length_of(:name).is_at_most(255) }
  end
  it { should have_and_belong_to_many :categories }
end
