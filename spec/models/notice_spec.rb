require 'spec_helper'

describe Notice do
  it { should validate_presence_of :title }
end
