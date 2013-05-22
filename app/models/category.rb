class Category < ActiveRecord::Base

  has_and_belongs_to_many :notices

  has_ancestry

  validates_presence_of :name

end
