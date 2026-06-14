require 'lumen/models'
require 'lumen/models/validates_automatically'

class TopicManager < ApplicationRecord
  include Lumen::Models::ValidatesAutomatically
  validates :name, length: { maximum: 255 }
  has_and_belongs_to_many :topics
end
