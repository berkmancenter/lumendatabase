require 'validates_automatically'

class CategoryManager < ActiveRecord::Base
  include ValidatesAutomatically
  has_and_belongs_to_many :categories
end
