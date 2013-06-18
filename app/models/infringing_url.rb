require 'validates_automatically'

class InfringingUrl < ActiveRecord::Base
  include ValidatesAutomatically
  has_and_belongs_to_many :works
  has_many :notices, through: :works

  validates_format_of :url, with: /^([a-z]{3,5}:)?\/\/.+/i
  validates_uniqueness_of :url
end
