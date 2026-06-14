require 'lumen/models'
require 'lumen/models/validates_automatically'

class BlockedTokenUrlIp < ApplicationRecord
  include Lumen::Models::ValidatesAutomatically
end
