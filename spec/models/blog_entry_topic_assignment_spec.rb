require 'spec_helper'

describe BlogEntryTopicAssignment, type: :model do
  it_behaves_like "a topic assigner of", :blog_entry
end
