require 'spec_helper'

describe InfringingUrl, type: :model do
  it { should_not have_db_index(:url).unique(true) }
  it { should have_db_index(:url_original).unique(true) }

  context 'automatic validations' do
    it { should validate_presence_of(:url_original) }
    it { should validate_length_of(:url).is_at_most(8.kilobytes) }
    it { should validate_length_of(:url_original).is_at_most(8.kilobytes) }
  end

  context "#url" do
    it_behaves_like 'an object with a url'
  end

  context "#url_original" do
    it_behaves_like 'an object with a url'
  end
end
