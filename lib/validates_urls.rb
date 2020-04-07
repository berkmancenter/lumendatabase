module ValidatesUrls
  MAX_LENGTH = 8.kilobytes

  def self.included(model)
    model.send(:validates, 'url'.freeze, { presence: true } )
    model.send(:validates, 'url_original'.freeze, { presence: true } )
    model.send(:validate, :good_urls?)
    model.send(:validate, :length_ok_when_split?)
    model.send(:after_initialize, :fixup_querystring)
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

  def length_ok_when_split?
    return false unless !!(url_text = self.send(:url))

    # Check if:
    # the URL is short enough on its own; or
    # the URL is concatenated and all individual pieces will be short enough; or
    # the URL will be short enough once its querystring is removed.
    # If any of these are correct, the URL will be valid once processed.
    [url_text.bytesize < MAX_LENGTH,
     url_text.split('/http')
             .map { |x| x.bytesize < (MAX_LENGTH - 5) }
             .all?,
     without_querystring(url_text).bytesize < MAX_LENGTH
    ].any?
  end

  def fixup_querystring
    url_text = self.send(:url) || ''
    return if url_text.bytesize < MAX_LENGTH

    shorter = without_querystring(url_text)

    self.send(:url=, shorter)
  end

  def without_querystring(url_text)
    Addressable::URI.parse(url_text).omit(:query).to_s
  end
end
