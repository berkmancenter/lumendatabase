require 'validates_urls'

class Url
  include ActiveModel::Model
  include ActiveModel::Validations
  include ValidatesUrls

  attr_accessor :url, :url_original

  def [](index)
    self.instance_variable_get("@#{index}")
  end

  def as_json(*)
    {
      url: self.url
    }
  end
end
