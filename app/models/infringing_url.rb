require 'validates_automatically'
require 'default_url_original'

class InfringingUrl < ActiveRecord::Base
  include ValidatesAutomatically
  include DefaultUrlOriginal

  validates_format_of :url, :url_original, with: /\A([a-z]{3,5}:)?\/\/.+/i
  validates_presence_of :url

  def self.get_approximate_count
  	Notice.convert_to_int(ActiveRecord::Base.connection.execute("SELECT reltuples FROM pg_class WHERE relname = 'infringing_urls'").getvalue(0, 0))
  end
end
