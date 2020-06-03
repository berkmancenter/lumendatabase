module ValidatesUrls
  MAX_LENGTH = 8.kilobytes

  def self.included(model)
    model.send(:validates, 'url'.freeze, { presence: true } )
    model.send(:validates, 'url_original'.freeze, { presence: true } )
    model.send(:validate, :good_urls?)
    model.send(:validate, :length_ok_when_split?)
  end

  private

  def good_urls?
    %i[url url_original].each do |attr|
      # URI::regexp will fail for things like "//bar.com", but we want to
      # allow those.
      value = self.send(attr)
      next unless value.present?

      # This is invalid per the spec but common, so let's allow it.
      munged_value = value.gsub('utf8=✓', 'utf8%3D%E2%9C%93')
      unless ( is_ordinary_uri?(munged_value) || is_noprotocol_uri?(munged_value) )
        errors.add(attr, 'Must be a valid URL')
      end
    end
  end

  # This isn't a very good URL validator, but when we use the proper one from
  # URI::regexp, 1) we reject a lot of data we're getting in the wild, and 2)
  # we can no longer add [REDACTED].
  def is_ordinary_uri?(value)
    !!(value =~ /\A([a-z]{3,5}:)?\/\/.+/i)
  end

  # Matches things like "//bar.com".
  def is_noprotocol_uri?(value)
    value.start_with?('//') && (('http:' + value) =~ /\A#{URI::regexp}\z/)
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
             .all?
    ].any?
  end
end
