require 'spec_helper'

describe Work do
  it { should have_and_belong_to_many :notices }
  it { should have_and_belong_to_many :infringing_urls }

  context '#url' do
    it_behaves_like 'an object with a url'
  end
end
