class Categorization < ActiveRecord::Base
  belongs_to :notice, touch: true
  belongs_to :category
end
