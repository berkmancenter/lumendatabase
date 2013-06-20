require 'categorizer'

class Categorization < ActiveRecord::Base
  extend Categorizer

  categorizes :notice, touch: true
end
