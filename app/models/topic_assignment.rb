require 'topic_assigner'

class TopicAssignment < ActiveRecord::Base
  extend TopicAssigner

  assigns_topic_to :notice, touch: true
  default_scope { includes(:topic) }
end
