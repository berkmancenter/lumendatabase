module ValidatesUrls
  MAX_LENGTH = 8.kilobytes

  def self.included(model)
    model.send(:validates, 'url'.freeze, { presence: true })
    model.send(:validates, 'url_original'.freeze, { presence: true })
  end
end
