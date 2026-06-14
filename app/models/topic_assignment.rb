require 'lumen/topics'
require 'lumen/topics/assigner'

class TopicAssignment < ApplicationRecord
  extend Lumen::Topics::Assigner

  assigns_topic_to :notice, touch: true
  default_scope { includes(:topic) }
end
