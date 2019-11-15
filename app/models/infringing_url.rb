require 'validates_automatically'
require 'default_url_original'

class InfringingUrl < ApplicationRecord
  include ValidatesAutomatically
  include DefaultUrlOriginal

  validates_format_of :url, :url_original, with: /\A([a-z]{3,5}:)?\/\/.+/i
  validates_presence_of :url

  def self.get_approximate_count
  	ActiveRecord::Base.connection.execute("SELECT reltuples FROM pg_class WHERE relname = 'infringing_urls'").getvalue(0, 0).to_i
  end
end
