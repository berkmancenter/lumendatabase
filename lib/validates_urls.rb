module ValidatesUrls
  def self.included(model)
    model.send(:validates, 'url'.freeze, { presence: true } )
    model.send(:validates, 'url_original'.freeze, { presence: true } )
    model.send(:validate, :good_urls?)
  end

  private

  def good_urls?
    %i[url url_original].each do |attr|
      # URI::regexp will fail for things like "//bar.com", but we want to
      # allow those.
      value = self.send(attr)
      next unless value.present?

      unless ( is_ordinary_uri?(value) || is_noprotocol_uri?(value) )
        errors.add(attr, 'Must be a valid URL')
      end
    end
  end

  def is_ordinary_uri?(value)
    !!(value =~ URI::regexp)
  end

  # Matches things like "//bar.com".
  def is_noprotocol_uri?(value)
    value.start_with?('//') && (('http:' + value) =~ URI::regexp)
  end
end
