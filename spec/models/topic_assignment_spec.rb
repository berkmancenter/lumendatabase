require 'spec_helper'

describe TopicAssignment, type: :model do
  it_behaves_like "a topic assigner of", :notice
end
