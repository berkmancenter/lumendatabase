require 'spec_helper'

describe InfringingUrl do
  it { should have_and_belong_to_many :works }
  it { should have_many(:notices).through(:works) }

  context 'schema_validations' do
    it { should validate_uniqueness_of(:url) }
  end

  context "#url" do
    it_behaves_like 'an object with a url'
  end
end
