require 'topic_assigner'

class BlogEntryTopicAssignment < ApplicationRecord
  extend TopicAssigner

  assigns_topic_to :blog_entry
end
