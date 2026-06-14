require 'lumen/models'
require 'lumen/models/validates_automatically'

class BlockedTokenUrlDomain < ApplicationRecord
  include Lumen::Models::ValidatesAutomatically
end
