require 'categorizer'

class BlogEntryCategorization < ActiveRecord::Base
  extend Categorizer

  categorizes :blog_entry
end
