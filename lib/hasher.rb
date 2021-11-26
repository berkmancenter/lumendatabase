module Hasher
  def self.hash512(string)
    Digest::SHA2.new(512).hexdigest("#{string}#{Chill::Application.config.secret_token}")
  end
end
