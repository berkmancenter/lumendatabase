# Monkeypatch to make the paperclip gem work with Ruby 3.x, remove it when
# the gem is fixed.

require 'uri'
require 'active_support/core_ext/module/delegation'

module Paperclip
  class UrlGenerator
    def escape_url(url)
      if url.respond_to?(:escape)
        url.escape
      else
        CGI.escape(url).gsub(escape_regex){|m| "%#{m.ord.to_s(16).upcase}" }
      end
    end
  end
end
