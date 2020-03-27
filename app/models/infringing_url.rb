require 'default_url_original'
require 'validates_automatically'
require 'validates_urls'

class InfringingUrl < ApplicationRecord
  include ValidatesAutomatically
  include DefaultUrlOriginal
  include ValidatesUrls

  def self.get_approximate_count
  	ActiveRecord::Base.connection.execute("SELECT reltuples FROM pg_class WHERE relname = 'infringing_urls'").getvalue(0, 0).to_i
  end
end
