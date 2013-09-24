require 'validates_automatically'

class TopicManager < ActiveRecord::Base
  include ValidatesAutomatically
  has_and_belongs_to_many :topics
end
