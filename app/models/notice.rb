class Notice < ActiveRecord::Base

  validates_presence_of :title

  attr_writer :file
end
