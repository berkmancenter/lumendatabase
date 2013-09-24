require 'topic_assigner'

class BlogEntryTopicAssignment < ActiveRecord::Base
  extend TopicAssigner

  assigns_topic_to :blog_entry
end
