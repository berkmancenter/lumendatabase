require 'validates_automatically'

class ArchivedTokenUrl < TokenUrl
  self.table_name = 'archived_token_urls'
end
