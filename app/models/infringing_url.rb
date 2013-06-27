require 'validates_automatically'

class InfringingUrl < ActiveRecord::Base
  include ValidatesAutomatically

  validates_format_of :url, with: /^([a-z]{3,5}:)?\/\/.+/i
  validates_uniqueness_of :url
end
