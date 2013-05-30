class Work < ActiveRecord::Base
  has_and_belongs_to_many :notices
  has_and_belongs_to_many :infringing_urls

  validates_presence_of :url
  validates_length_of :url, maximum: 1.kilobyte
  validates_format_of :url, with: /^([a-z]{3,5}:)?\/\/.+/i
end
