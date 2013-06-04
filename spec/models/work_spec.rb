require 'spec_helper'

describe Work do
  it { should have_and_belong_to_many :notices }
  it { should have_and_belong_to_many :infringing_urls }

  context 'schema_validations' do
    it { should ensure_length_of(:kind).is_at_most(255) }
  end

  context '#url' do
    it_behaves_like 'an object with a url'
  end
end
