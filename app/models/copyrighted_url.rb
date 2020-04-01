require 'default_url_original'
require 'validates_automatically'
require 'validates_urls'

class CopyrightedUrl < ApplicationRecord
  include ValidatesAutomatically
  include DefaultUrlOriginal
  include ValidatesUrls
end
