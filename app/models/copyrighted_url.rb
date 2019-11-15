require 'validates_automatically'
require 'default_url_original'

class CopyrightedUrl < ApplicationRecord
  include ValidatesAutomatically
  include DefaultUrlOriginal

  validates_format_of :url, :url_original, with: /\A([a-z]{3,5}:)?\/\/.+/i
end
