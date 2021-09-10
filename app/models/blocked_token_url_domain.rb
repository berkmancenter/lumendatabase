require 'validates_automatically'

class BlockedTokenUrlDomain < ApplicationRecord
  validates :name, presence: true
end
