require 'spec_helper'

describe Role, type: :model do
  context ".default" do
    it "is equal to redactor" do
      expect(Role.default).to eq Role.redactor
    end
  end
end
