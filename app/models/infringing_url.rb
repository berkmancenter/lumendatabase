class InfringingUrl < ActiveRecord::Base
  has_and_belongs_to_many :works
  has_many :notices, through: :works

  validates_format_of :url, with: /^([a-z]{3,5}:)?\/\/.+/i
end
