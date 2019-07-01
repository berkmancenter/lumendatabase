require 'spec_helper'

describe 'validate FactoryBot factories' do
  FactoryBot.factories.each do |factory|
    context "with factory for :#{factory.name}" do
      subject { FactoryBot.build(factory.name) }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end
end
