require 'validates_automatically'

class TopicManager < ActiveRecord::Base
  include ValidatesAutomatically
  validates :name, length: { maximum: 255 }
  has_and_belongs_to_many :topics
end
