require 'spec_helper'

describe CopyrightedUrl do
  it { should have_db_index(:url).unique(true) }

  context 'automatic validations' do
    it { should validate_presence_of(:url) }
    it { should ensure_length_of(:url).is_at_most(8.kilobytes) }
  end

  context "#url" do
    it_behaves_like 'an object with a url'
  end
end
