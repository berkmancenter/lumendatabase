require 'spec_helper'

describe InfringingUrl do
  it { should validate_uniqueness_of(:url) }

  context 'automatic validations' do
    it { should validate_presence_of(:url) }
    it { should ensure_length_of(:url).is_at_most(1.kilobyte) }
  end

  context "#url" do
    it_behaves_like 'an object with a url'
  end
end
